#!/usr/bin/env python3
"""Wickwarden sprite cut tool (docs/asset-contract.md sections 1, 4-8).

    uv run --with pillow==12.3.0 --with numpy python tools/cut_sprites.py [sheet ...]

Reads tools/source_art/<sheet>.png (flat key background) and tools/art_manifest.json. Writes
assets/sprites/*.png, assets/sprites/sprites.json and proof sheets in tools/source_art/proofs/.

Post-processing is never destructive: soft alpha (no threshold), no palette quantization, one scale
factor per scale group (never per frame), LANCZOS on premultiplied colour, textures made seamless by
an offset cross-fade. See the manifest header for the schema.
"""

from __future__ import annotations

import argparse
import json
import math
import sys
from dataclasses import dataclass, field
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_MANIFEST = ROOT / "tools" / "art_manifest.json"
DEFAULT_SOURCE = ROOT / "tools" / "source_art"
DEFAULT_OUT = ROOT / "assets" / "sprites"
RES_PREFIX = "res://assets/sprites/"

NOMINAL_KEYS = {"green": (0.0, 255.0, 0.0), "magenta": (255.0, 0.0, 255.0)}

DEFAULTS: dict = {
    "key_border": 16,  # px of the outer band used to measure the real key colour
    "ramp": [28.0, 110.0],  # colour distance where alpha starts / reaches 1
    "chroma": True,  # also drop alpha where a pixel leans toward the key hue (edge band only)
    "chroma_k0": 15.0,  # key-hue lean (0..255) below which chroma never lowers alpha
    "chroma_kc": -40.0,  # assumed key-hue lean of the subject colour at full coverage
    "chroma_span": 40.0,  # lean range over which the chroma term fades in
    "chroma_band": 8,  # px around the background where the chroma term may act
    "refine": True,  # re-estimate alpha on the 1-2 px rim from the nearest interior colour
    "residual_tol": 30.0,  # a rim pixel must lie this close to the line subject..key
    "det_floor": 0.04,  # alpha floor used ONLY to detect content (segmentation)
    "measure_floor": 0.10,  # alpha floor for measuring height / width / feet
    "min_gap": 10,  # narrower empty column runs do not split poses
    "min_gap_y": 6,  # narrower empty row runs do not split bands
    "noise_area": 150,  # clusters with fewer mask pixels are noise or detached parts
    "speck_area": 16,  # connected components smaller than this are erased
    "merge_dist": 70,  # a small detached part merges into a pose this close
    "crop_pad": 2,
    "shadow_frac": 0.30,  # lowest fraction of the figure used to size the contact shadow
    "clip_tolerance": 0,  # px a pose may exceed its cell before the cut fails
}


class CutError(Exception):
    """A sheet cannot be cut; main() reports it and exits non-zero."""


# --------------------------------------------------------------------------------------------
# small numpy helpers
# --------------------------------------------------------------------------------------------


def smoothstep(x):
    x = np.clip(x, 0.0, 1.0)
    return x * x * (3.0 - 2.0 * x)


def runs_of(flags: np.ndarray) -> list[list[int]]:
    """Runs of True as [start, end) pairs."""
    padded = np.concatenate(([0], np.asarray(flags).astype(np.int8), [0]))
    diff = np.diff(padded)
    return [[int(s), int(e)] for s, e in zip(np.flatnonzero(diff == 1), np.flatnonzero(diff == -1))]


def merge_close(runs: list[list[int]], gap: int) -> list[list[int]]:
    """Join runs separated by fewer than `gap` empty cells."""
    merged: list[list[int]] = []
    for run in runs:
        if merged and run[0] - merged[-1][1] < gap:
            merged[-1][1] = run[1]
        else:
            merged.append(list(run))
    return merged


def run_distance(a: list[int], b: list[int]) -> int:
    if a[1] <= b[0]:
        return b[0] - a[1]
    if b[1] <= a[0]:
        return a[0] - b[1]
    return 0


def propagate(rgb: np.ndarray, valid: np.ndarray, iters: int):
    """Spread colour from `valid` pixels outward (8-neighbour mean), `iters` pixels deep."""
    rgb = rgb.copy()
    valid = valid.copy()
    h, w = valid.shape
    for _ in range(iters):
        if valid.all():
            break
        v = valid.astype(np.float32)
        pr = np.pad(rgb * v[..., None], ((1, 1), (1, 1), (0, 0)))
        pv = np.pad(v, 1)
        acc = np.zeros_like(rgb)
        cnt = np.zeros(valid.shape, np.float32)
        for dy in (-1, 0, 1):
            for dx in (-1, 0, 1):
                if dy == 0 and dx == 0:
                    continue
                acc += pr[1 + dy : 1 + dy + h, 1 + dx : 1 + dx + w]
                cnt += pv[1 + dy : 1 + dy + h, 1 + dx : 1 + dx + w]
        new = (~valid) & (cnt > 0)
        rgb[new] = acc[new] / cnt[new][:, None]
        valid |= new
    return rgb, valid


def erode3(mask: np.ndarray) -> np.ndarray:
    """True where the whole 3x3 neighbourhood is True."""
    h, w = mask.shape
    p = np.pad(mask, 1, constant_values=False)
    out = np.ones_like(mask)
    for dy in (-1, 0, 1):
        for dx in (-1, 0, 1):
            out &= p[1 + dy : 1 + dy + h, 1 + dx : 1 + dx + w]
    return out


# --------------------------------------------------------------------------------------------
# key removal
# --------------------------------------------------------------------------------------------


def estimate_key(rgb: np.ndarray, border: int) -> np.ndarray:
    """Median colour of the outer band: generated 'flat' keys drift, so measure them."""
    b = max(1, min(border, rgb.shape[0] // 4, rgb.shape[1] // 4))
    band = np.concatenate(
        [
            rgb[:b].reshape(-1, 3),
            rgb[-b:].reshape(-1, 3),
            rgb[b:-b, :b].reshape(-1, 3),
            rgb[b:-b, -b:].reshape(-1, 3),
        ]
    )
    return np.median(band, axis=0).astype(np.float32)


def keyness(rgb: np.ndarray, key_name: str) -> np.ndarray:
    """How far a colour leans toward the key hue, 0..255 (the pure key is 255)."""
    if key_name == "green":
        return rgb[..., 1] - np.maximum(rgb[..., 0], rgb[..., 2])
    return np.minimum(rgb[..., 0], rgb[..., 2]) - rgb[..., 1]


def dilate3(mask: np.ndarray, times: int) -> np.ndarray:
    h, w = mask.shape
    out = mask.copy()
    for _ in range(times):
        p = np.pad(out, 1, constant_values=False)
        grown = out.copy()
        for dy in (-1, 0, 1):
            for dx in (-1, 0, 1):
                grown |= p[1 + dy : 1 + dy + h, 1 + dx : 1 + dx + w]
        out = grown
    return out


def border_connected(mask: np.ndarray) -> np.ndarray:
    """Components of `mask` that touch the image border (the background and what hangs off it)."""
    h, w = mask.shape
    runs, comp, _ = label_components(mask)
    touching = {
        comp[i] for i, (y, x0, x1) in enumerate(runs) if y == 0 or y == h - 1 or x0 == 0 or x1 == w
    }
    out = np.zeros_like(mask)
    for i, (y, x0, x1) in enumerate(runs):
        if comp[i] in touching:
            out[y, x0:x1] = True
    return out


def despill_partial(rgb: np.ndarray, key_name: str, margin: float = 10.0) -> np.ndarray:
    """Remove the remaining key-hue lean from colours (used on partly transparent pixels only)."""
    lean = np.maximum(keyness(rgb, key_name) + margin, 0.0)[..., None]
    out = rgb.copy()
    if key_name == "green":
        out[..., 1:2] -= lean
    else:
        out[..., 0:1] -= lean
        out[..., 2:3] -= lean
    return np.clip(out, 0.0, 255.0)


def matte(rgb: np.ndarray, key: np.ndarray, params: dict, key_name: str = "magenta"):
    """Soft key removal. rgb is float32 0..255. Returns (rgb, alpha 0..1), straight alpha.

    Alpha: linear ramp of the colour distance to the key between two thresholds (continuous). In
    the band around the background it is also lowered where a pixel leans toward the key hue, so
    pale translucent edges (smoke, cloak tatters) do not stay opaque and pink. Despill touches ONLY
    partly transparent pixels (and the 1 px rim that is a real blend with the key), un-premultiplying
    with alpha as coverage. Opaque interior pixels are never changed.
    """
    lo, hi = float(params["ramp"][0]), float(params["ramp"][1])
    dist = np.linalg.norm(rgb - key, axis=2)
    a_dist = np.clip((dist - lo) / (hi - lo), 0.0, 1.0).astype(np.float32)
    a0 = a_dist
    if params["chroma"]:
        kn = keyness(rgb, key_name)
        raw = np.clip((255.0 - kn) / (255.0 - params["chroma_kc"]), 0.0, 1.0)
        fade = smoothstep((kn - params["chroma_k0"]) / params["chroma_span"])
        a_chroma = (1.0 - fade * (1.0 - raw)).astype(np.float32)
        combined = np.minimum(a_dist, a_chroma)
        outside = border_connected(combined < 0.8) | (combined < 0.6)
        band = dilate3(outside, int(params["chroma_band"]))
        a0 = np.where(band, combined, a_dist).astype(np.float32)
    core = a0 >= 0.999
    interior = erode3(core)
    fg, fg_valid = propagate(rgb, interior, 4)
    alpha = a0.copy()
    if params["refine"]:
        fk = fg - key
        denom = (fk * fk).sum(axis=2)
        pk = rgb - key
        t = np.clip((pk * fk).sum(axis=2) / np.maximum(denom, 1.0), 0.0, 1.0)
        recon = key + t[..., None] * fk
        resid = np.linalg.norm(rgb - recon, axis=2)
        rim = core & ~interior
        edge = ((a0 > 0.0) & ~core) | rim
        ok = edge & fg_valid & (denom > 60.0**2) & (resid < params["residual_tol"]) & (a0 > 0.0)
        alpha = np.where(ok & (t < 0.97), t, alpha).astype(np.float32)
    partial = (alpha > 0.0) & (alpha < 0.97)
    safe = np.maximum(alpha, 1e-3)[..., None]
    unpremult = np.clip(key + (rgb - key) / safe, 0.0, 255.0)
    mix = smoothstep((alpha - 0.08) / 0.37)[..., None]
    blended = np.where(fg_valid[..., None], fg + (unpremult - fg) * mix, unpremult)
    blended = despill_partial(blended, key_name)
    out = np.where(partial[..., None], blended, rgb)
    # transparent pixels take the nearest subject colour so bilinear filtering never bleeds the key
    clear = alpha <= 0.0
    out = np.where(clear[..., None], np.where(fg_valid[..., None], fg, 0.0), out)
    return out.astype(np.float32), alpha


def label_components(mask: np.ndarray):
    """8-connected components by run-length union-find. Returns (runs, comp id per run, areas)."""
    runs: list[tuple[int, int, int]] = []  # (y, x0, x1) with x1 exclusive
    row_index: list[tuple[int, int]] = []
    for y in range(mask.shape[0]):
        start = len(runs)
        for x0, x1 in runs_of(mask[y]):
            runs.append((y, x0, x1))
        row_index.append((start, len(runs)))
    parent = list(range(len(runs)))

    def find(i):
        while parent[i] != i:
            parent[i] = parent[parent[i]]
            i = parent[i]
        return i

    for y in range(1, mask.shape[0]):
        ps, pe = row_index[y - 1]
        cs, ce = row_index[y]
        i = ps
        for j in range(cs, ce):
            _, b0, b1 = runs[j]
            while i < pe and runs[i][2] < b0:  # previous run ends left of b0 - 1
                i += 1
            k = i
            while k < pe and runs[k][1] <= b1:
                if runs[k][2] >= b0:
                    ra, rb = find(k), find(j)
                    if ra != rb:
                        parent[rb] = ra
                k += 1
    comp = [find(i) for i in range(len(runs))]
    areas: dict[int, int] = {}
    for idx, (_, x0, x1) in enumerate(runs):
        areas[comp[idx]] = areas.get(comp[idx], 0) + (x1 - x0)
    return runs, comp, areas


def remove_specks(alpha: np.ndarray, floor: float, min_area: int) -> np.ndarray:
    """Erase connected components below `min_area` pixels (noise). Soft alpha is kept elsewhere."""
    runs, comp, areas = label_components(alpha > floor)
    out = alpha.copy()
    for idx, (y, x0, x1) in enumerate(runs):
        if areas[comp[idx]] < min_area:
            out[y, x0:x1] = 0.0
    return out


# --------------------------------------------------------------------------------------------
# segmentation
# --------------------------------------------------------------------------------------------


@dataclass
class Pose:
    sheet: str
    row: int
    index: int
    rgba: np.ndarray  # float32 H x W x 4: rgb 0..255 straight, alpha 0..1
    origin: tuple[int, int]  # (x, y) of rgba[0, 0] in the sheet
    bbox: tuple[int, int, int, int]  # x0, y0, x1, y1 (exclusive) of alpha > measure_floor, in rgba

    @property
    def width(self) -> int:
        return self.bbox[2] - self.bbox[0]

    @property
    def height(self) -> int:
        return self.bbox[3] - self.bbox[1]

    @property
    def bottom_src(self) -> int:
        """Sheet y just below the lowest opaque row."""
        return self.origin[1] + self.bbox[3]


def alpha_bbox(alpha: np.ndarray, floor: float):
    rows = np.flatnonzero((alpha > floor).any(axis=1))
    cols = np.flatnonzero((alpha > floor).any(axis=0))
    if len(rows) == 0:
        return None
    return int(cols[0]), int(rows[0]), int(cols[-1]) + 1, int(rows[-1]) + 1


def _split_tiny(runs, sizes, noise_area, merge_dist):
    """Big runs keep their own place; tiny ones merge into the nearest big run or are dropped."""
    big = [i for i, s in enumerate(sizes) if s >= noise_area]
    kept = [list(runs[i]) for i in big]
    for i, s in enumerate(sizes):
        if s >= noise_area or not kept:
            continue
        dists = [run_distance(runs[i], k) for k in kept]
        j = int(np.argmin(dists))
        if dists[j] <= merge_dist:
            kept[j] = [min(kept[j][0], runs[i][0]), max(kept[j][1], runs[i][1])]
    return kept


@dataclass
class Seg:
    """One pose found in a band. `labels` (component ids, band relative) is only set for
    split="components" rows, where neighbouring props may overlap in x."""

    box: tuple[int, int, int, int]
    labels: np.ndarray | None = None
    ids: frozenset = frozenset()
    y_off: int = 0


def label_image(mask: np.ndarray):
    """(labels int32 with ids from 1, {id: area}) for 8-connected components of `mask`."""
    runs, comp, areas = label_components(mask)
    ids: dict[int, int] = {}
    labels = np.zeros(mask.shape, np.int32)
    for i, (y, x0, x1) in enumerate(runs):
        cid = ids.setdefault(comp[i], len(ids) + 1)
        labels[y, x0:x1] = cid
    return labels, {ids[k]: v for k, v in areas.items()}


def _component_segs(mask: np.ndarray, y0: int, rp: dict) -> list[Seg]:
    """Poses as connected components (clusters of components for small detached parts)."""
    labels, areas = label_image(mask)
    boxes: dict[int, list[int]] = {}
    for cid in areas:
        ys, xs = np.nonzero(labels == cid)
        boxes[cid] = [int(xs.min()), int(ys.min()), int(xs.max()) + 1, int(ys.max()) + 1]
    big = [c for c, a in areas.items() if a >= rp["noise_area"]]
    members = {c: {c} for c in big}
    for cid in areas:
        if cid in members or not big:
            continue
        b = boxes[cid]
        dists = []
        for c in big:
            o = boxes[c]
            dx = run_distance([b[0], b[2]], [o[0], o[2]])
            dy = run_distance([b[1], b[3]], [o[1], o[3]])
            dists.append(math.hypot(dx, dy))
        j = int(np.argmin(dists))
        if dists[j] <= rp["merge_dist"]:
            members[big[j]].add(cid)
    segs = []
    for c in big:
        ids = frozenset(members[c])
        bb = np.array([boxes[i] for i in ids])
        box = (int(bb[:, 0].min()), y0 + int(bb[:, 1].min()), int(bb[:, 2].max()), y0 + int(bb[:, 3].max()))
        segs.append(Seg(box, labels, ids, y0))
    segs.sort(key=lambda sg: sg.box[0])
    return segs


def segment(alpha: np.ndarray, params: dict, row_params: list[dict]) -> list[list[Seg]]:
    """Row bands, then real column gaps inside each band (or components, per row)."""
    mask = alpha > params["det_floor"]
    rowcnt = mask.sum(axis=1)
    bands = merge_close(runs_of(rowcnt > 0), params["min_gap_y"])
    sizes = [int(rowcnt[a:b].sum()) for a, b in bands]
    bands = _split_tiny(bands, sizes, params["noise_area"], params["merge_dist"])
    bands.sort()
    result = []
    for band_idx, (y0, y1) in enumerate(bands):
        rp = row_params[band_idx] if band_idx < len(row_params) else params
        sub = mask[y0:y1]
        if rp.get("split") == "components":
            result.append(_component_segs(sub, y0, rp))
            continue
        colcnt = sub.sum(axis=0)
        clusters = merge_close(runs_of(colcnt > 0), rp["min_gap"])
        csizes = [int(colcnt[a:b].sum()) for a, b in clusters]
        clusters = _split_tiny(clusters, csizes, rp["noise_area"], rp["merge_dist"])
        clusters.sort()
        segs = []
        for x0, x1 in clusters:
            cell = sub[:, x0:x1]
            rows = np.flatnonzero(cell.any(axis=1))
            cols = np.flatnonzero(cell.any(axis=0))
            box = (x0 + int(cols[0]), y0 + int(rows[0]), x0 + int(cols[-1]) + 1, y0 + int(rows[-1]) + 1)
            segs.append(Seg(box))
        result.append(segs)
    return result


# --------------------------------------------------------------------------------------------
# sheets
# --------------------------------------------------------------------------------------------


def merged_params(manifest: dict, sheet_def: dict, row_def: dict | None = None) -> dict:
    params = dict(DEFAULTS)
    params.update(manifest.get("defaults", {}))
    params.update(sheet_def.get("params", {}))
    if row_def:
        params.update(row_def.get("params", {}))
    return params


@dataclass
class SheetData:
    name: str
    rgba: np.ndarray
    key: np.ndarray
    params: dict
    rows: list[list[Pose]]
    boxes: list[list[tuple[int, int, int, int]]]


class Context:
    """Lazy, cached access to the cut poses of every sheet (reference rows may live elsewhere)."""

    def __init__(self, manifest: dict, source_dir: Path):
        self.manifest = manifest
        self.source_dir = source_dir
        self._sheets: dict[str, SheetData] = {}

    def sheet(self, name: str) -> SheetData:
        if name not in self._sheets:
            self._sheets[name] = self._load(name)
        return self._sheets[name]

    def _load(self, name: str) -> SheetData:
        sheet_def = self.manifest["sheets"].get(name)
        if sheet_def is None:
            raise CutError(f"sheet {name}: not in the manifest")
        path = self.source_dir / f"{name}.png"
        if not path.exists():
            raise CutError(f"sheet {name}: source image missing ({path})")
        params = merged_params(self.manifest, sheet_def)
        rgb = np.asarray(Image.open(path).convert("RGB"), dtype=np.float32)
        key = estimate_key(rgb, params["key_border"])
        nominal = np.array(NOMINAL_KEYS[sheet_def["key"]], np.float32)
        if np.linalg.norm(key - nominal) > 90.0:
            print(f"warning: {name}: measured key {key.round().tolist()} is far from {sheet_def['key']}")
        rgb_out, alpha = matte(rgb, key, params, sheet_def["key"])
        alpha = remove_specks(alpha, params["det_floor"], params["speck_area"])
        rgba = np.concatenate([rgb_out, alpha[..., None]], axis=2)
        rows_def = sheet_def["rows"]
        row_params = [merged_params(self.manifest, sheet_def, r) for r in rows_def]
        boxes = segment(alpha, params, row_params)
        if len(boxes) != len(rows_def):
            raise CutError(f"sheet {name}: found {len(boxes)} rows, expected {len(rows_def)}")
        rows: list[list[Pose]] = []
        for r, (row_def, row_boxes) in enumerate(zip(rows_def, boxes)):
            if row_def.get("skip"):  # rejected row: counts for row detection, is never cut
                rows.append([])
                continue
            if len(row_boxes) != row_def["poses"]:
                raise CutError(
                    f"sheet {name} row {r}: found {len(row_boxes)} poses, expected {row_def['poses']}"
                )
            pad = row_params[r]["crop_pad"]
            poses = []
            for i, seg in enumerate(row_boxes):
                x0, y0, x1, y1 = seg.box
                cx0, cy0 = max(0, x0 - pad), max(0, y0 - pad)
                cx1, cy1 = min(rgba.shape[1], x1 + pad), min(rgba.shape[0], y1 + pad)
                crop = rgba[cy0:cy1, cx0:cx1].copy()
                if seg.labels is not None:  # erase neighbours that overlap this pose's box
                    lab = np.zeros(crop.shape[:2], np.int32)
                    ly0, ly1 = cy0 - seg.y_off, cy1 - seg.y_off
                    sy0, sy1 = max(0, ly0), min(seg.labels.shape[0], ly1)
                    lab[sy0 - ly0 : sy1 - ly0] = seg.labels[sy0:sy1, cx0:cx1]
                    foreign = (lab > 0) & ~np.isin(lab, list(seg.ids))
                    crop[foreign, 3] = 0.0
                bbox = alpha_bbox(crop[..., 3], row_params[r]["measure_floor"])
                poses.append(Pose(name, r, i, crop, (cx0, cy0), bbox))
            rows.append(poses)
        return SheetData(name, rgba, key, params, rows, [[sg.box for sg in r] for r in boxes])


# --------------------------------------------------------------------------------------------
# scaling and placement
# --------------------------------------------------------------------------------------------


def select_poses(spec, count: int) -> list[int]:
    if spec is None:
        return list(range(count))
    if isinstance(spec, int):
        return [spec]
    return list(range(spec[0], spec[1]))


def scale_factor(gdef: dict, ctx: Context, own: list[Pose]) -> float:
    """One factor for a whole scale group, from the reference poses (or the output's own poses)."""
    refs: list[Pose] = []
    if gdef.get("ref"):
        for ref in gdef["ref"]:
            row = ctx.sheet(ref["sheet"]).rows[ref["row"]]
            refs += [row[i] for i in select_poses(ref.get("poses"), len(row))]
    else:
        refs = own
    measure, value = gdef["measure"], gdef["value"]
    if measure == "fit":
        return min(min(value[0] / p.width, value[1] / p.height) for p in refs)
    pick = {
        "height": lambda p: p.height,
        "width": lambda p: p.width,
        "extent": lambda p: max(p.width, p.height),
    }[measure]
    return float(value) / max(pick(p) for p in refs)


def resize_rgba(rgba: np.ndarray, factor: float) -> np.ndarray:
    """LANCZOS on premultiplied colour (no dark or key-coloured fringes). Returns straight RGBA."""
    h, w = rgba.shape[:2]
    nw, nh = max(1, round(w * factor)), max(1, round(h * factor))
    a = rgba[..., 3]
    chans = [rgba[..., c] * a for c in range(3)] + [a]
    scaled = []
    for ch in chans:
        img = Image.fromarray(np.ascontiguousarray(ch, dtype=np.float32), mode="F")
        scaled.append(np.asarray(img.resize((nw, nh), Image.LANCZOS), dtype=np.float32))
    alpha = np.clip(scaled[3], 0.0, 1.0)
    out = np.zeros((nh, nw, 4), np.float32)
    live = alpha > 1e-4
    for c in range(3):
        pm = np.clip(scaled[c], 0.0, alpha * 255.0)
        out[..., c] = np.where(live, pm / np.maximum(alpha, 1e-4), 0.0)
    out[..., 3] = alpha
    return out


def bleed(rgba: np.ndarray, iters: int = 4) -> np.ndarray:
    """Give fully transparent pixels the colour of the nearest subject pixel (filter safety)."""
    rgb, _ = propagate(rgba[..., :3], rgba[..., 3] > 0.004, iters)
    out = rgba.copy()
    out[..., :3] = rgb
    return out


def body_centre_x(frame: np.ndarray, bbox) -> float:
    """Alpha mass centre of the lower half of the pose."""
    x0, y0, x1, y1 = bbox
    mid = (y0 + y1) // 2
    sub = frame[mid:y1, :, 3]
    total = sub.sum()
    if total <= 0:
        return (x0 + x1) / 2.0
    return float((sub.sum(axis=0) * (np.arange(frame.shape[1]) + 0.5)).sum() / total)


def centroid(frame: np.ndarray):
    a = frame[..., 3]
    total = a.sum()
    ys = (a.sum(axis=1) * (np.arange(a.shape[0]) + 0.5)).sum() / total
    xs = (a.sum(axis=0) * (np.arange(a.shape[1]) + 0.5)).sum() / total
    return float(xs), float(ys)


@dataclass
class OutputResult:
    name: str
    kind: str
    anim: str
    frames: list[np.ndarray]  # cell sized, float RGBA
    cell: tuple[int, int]
    align: str
    foot: int
    fps: float
    loop: bool
    shadow_widths: list[float]
    out_def: dict
    notes: list[str] = field(default_factory=list)


def build_output(out_def: dict, kind_def: dict, ctx: Context, sheet: SheetData, row: int) -> OutputResult:
    row_def = ctx.manifest["sheets"][sheet.name]["rows"][row]
    row_poses = sheet.rows[row]
    idx = select_poses(out_def.get("poses"), len(row_poses))
    poses = [row_poses[i] for i in idx]
    gdef = out_def["scale"]
    if isinstance(gdef, str):
        gdef = ctx.manifest["scale_groups"][gdef]
    factor = scale_factor(gdef, ctx, poses)
    cell_w, cell_h = kind_def["cell"]
    align = kind_def.get("align", "foot")
    foot = int(kind_def.get("foot", cell_h - 1))
    params = sheet.params
    floor = params["measure_floor"]
    ground_src = None
    if out_def.get("ground", "pose") == "row":
        gp = select_poses(row_def.get("ground_poses"), len(row_poses))
        ground_src = float(np.median([row_poses[i].bottom_src for i in gp]))
    notes: list[str] = []
    frames: list[np.ndarray] = []
    shadow_widths: list[float] = []
    where = f"{out_def['file']} (sheet {sheet.name} row {row})"
    for i, pose in zip(idx, poses):
        scaled = resize_rgba(pose.rgba, factor)
        bbox = alpha_bbox(scaled[..., 3], floor)
        if bbox is None:
            raise CutError(f"{where}: pose {i} vanished after scaling")
        bx0, by0, bx1, by1 = bbox
        if align == "center":
            cx, cy = centroid(scaled)
            dx = round(cell_w / 2.0 - cx)
            dy = round(cell_h / 2.0 - cy)
        else:
            cx = body_centre_x(scaled, bbox)
            dx = round(cell_w / 2.0 - cx)
            if ground_src is None:
                dy = foot + 1 - by1
            else:
                dy = round(foot + 1 - (ground_src - pose.origin[1]) * factor)
        # keep the whole pose inside the cell: slide it, never crop it
        shift_x = 0
        if bx0 + dx < 0:
            shift_x = -(bx0 + dx)
        elif bx1 + dx > cell_w:
            shift_x = cell_w - (bx1 + dx)
        tol = int(params["clip_tolerance"])
        if (bx1 - bx0) > cell_w + tol or (by1 - by0) > cell_h + tol:
            raise CutError(f"{where}: pose {i} is {bx1 - bx0}x{by1 - by0} px, larger than the {cell_w}x{cell_h} cell")
        dx += shift_x
        if shift_x:
            notes.append(f"pose {i} slid {shift_x:+d} px to stay in the cell")
        if by0 + dy < -tol or by1 + dy > cell_h + tol:
            raise CutError(
                f"{where}: pose {i} leaves the cell vertically (top {by0 + dy}, bottom {by1 + dy} of {cell_h})"
            )
        cell = np.zeros((cell_h, cell_w, 4), np.float32)
        # paste with clipping for the (sub-floor) soft fringe only
        sy0, sx0 = max(0, -dy), max(0, -dx)
        sy1 = min(scaled.shape[0], cell_h - dy)
        sx1 = min(scaled.shape[1], cell_w - dx)
        cell[sy0 + dy : sy1 + dy, sx0 + dx : sx1 + dx] = scaled[sy0:sy1, sx0:sx1]
        frames.append(bleed(cell))
        low = by1 - max(1, int(round((by1 - by0) * params["shadow_frac"])))
        cols = np.flatnonzero((scaled[low:by1, :, 3] > floor).any(axis=0))
        if len(cols):
            shadow_widths.append(float(cols[-1] - cols[0] + 1))
    return OutputResult(
        name=out_def["file"],
        kind=out_def["kind"],
        anim=out_def["anim"],
        frames=frames,
        cell=(cell_w, cell_h),
        align=align,
        foot=foot,
        fps=float(out_def.get("fps", 1)),
        loop=bool(out_def.get("loop", True)),
        shadow_widths=shadow_widths if out_def.get("shadow_src") else [],
        out_def=out_def,
        notes=notes,
    )


def to_uint8(rgba: np.ndarray) -> np.ndarray:
    out = np.empty(rgba.shape, np.uint8)
    out[..., :3] = np.clip(np.rint(rgba[..., :3]), 0, 255)
    out[..., 3] = np.clip(np.rint(rgba[..., 3] * 255.0), 0, 255)
    return out


def write_png(path: Path, array: np.ndarray, mode: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    Image.fromarray(array, mode=mode).save(path, format="PNG", optimize=False, compress_level=6)


def write_strip(path: Path, frames: list[np.ndarray]) -> None:
    write_png(path, to_uint8(np.concatenate(frames, axis=1)), "RGBA")


# --------------------------------------------------------------------------------------------
# textures
# --------------------------------------------------------------------------------------------


def make_seamless(arr: np.ndarray, blend: float = 0.2, variance_preserve: bool = True) -> np.ndarray:
    """Seamless in both axes. Offset the image by half so its wrap seam sits in the middle, then
    cross-fade the original over it with a mask that is 0 at the borders and 1 in the middle: the
    borders show the shifted copy (continuous when it wraps), the middle shows the original."""
    h, w = arr.shape[:2]
    shifted = np.roll(arr, (h // 2, w // 2), axis=(0, 1))
    ty = (np.arange(h) + 0.5) / h
    tx = (np.arange(w) + 0.5) / w
    wy = smoothstep(np.minimum(ty, 1 - ty) / blend)
    wx = smoothstep(np.minimum(tx, 1 - tx) / blend)
    m = (wy[:, None] * wx[None, :])[..., None]
    mean = arr.mean(axis=(0, 1), keepdims=True)
    mixed = m * (arr - mean) + (1 - m) * (shifted - mean)
    if variance_preserve:
        mixed = mixed / np.sqrt(m * m + (1 - m) * (1 - m))
    return np.clip(mean + mixed, 0.0, 255.0)


def make_texture(img: Image.Image, size: int, blend: float, variance_preserve: bool) -> np.ndarray:
    small = img.convert("RGB").resize((size, size), Image.LANCZOS)
    arr = np.asarray(small, dtype=np.float32)
    return np.clip(np.rint(make_seamless(arr, blend, variance_preserve)), 0, 255).astype(np.uint8)


# --------------------------------------------------------------------------------------------
# proofs
# --------------------------------------------------------------------------------------------

CHECK_A = np.array([46, 49, 58], np.float32)
CHECK_B = np.array([32, 34, 42], np.float32)


def checker(h: int, w: int, size: int = 16) -> np.ndarray:
    yy, xx = np.mgrid[0:h, 0:w]
    pick = ((yy // size + xx // size) % 2 == 0)[..., None]
    return np.where(pick, CHECK_A, CHECK_B).astype(np.float32)


def over_checker(rgba: np.ndarray) -> np.ndarray:
    bg = checker(*rgba.shape[:2])
    a = rgba[..., 3:4]
    return bg * (1 - a) + rgba[..., :3] * a


def font(size: int):
    try:
        return ImageFont.load_default(size=size)
    except Exception:  # pragma: no cover - old Pillow without FreeType
        return ImageFont.load_default()


def proof_for_outputs(sheet: SheetData | None, outputs: list[OutputResult], path: Path) -> None:
    width_limit = 2000
    f = font(15)
    blocks = []
    for out in outputs:
        strip = np.concatenate(out.frames, axis=1)
        img = Image.fromarray(over_checker(strip).astype(np.uint8), "RGB")
        d = ImageDraw.Draw(img)
        cw, ch = out.cell
        for n in range(len(out.frames)):
            x = n * cw
            d.rectangle([x, 0, x + cw - 1, ch - 1], outline=(70, 130, 220))
            if out.align == "center":
                d.line([x + cw // 2 - 8, ch // 2, x + cw // 2 + 8, ch // 2], fill=(240, 90, 60))
                d.line([x + cw // 2, ch // 2 - 8, x + cw // 2, ch // 2 + 8], fill=(240, 90, 60))
            else:
                d.line([x, out.foot, x + cw - 1, out.foot], fill=(240, 90, 60))
                d.line([x + cw // 2, out.foot - 6, x + cw // 2, out.foot], fill=(240, 90, 60))
        blocks.append((out.name, img))
    seg = None
    if sheet is not None:
        seg = segmentation_overview(sheet)
    x = y = row_h = 8
    placed = []
    y = 8
    if seg is not None:
        placed.append((seg, 8, y))
        y += seg.height + 28
    x = 8
    row_h = 0
    for name, img in blocks:
        if x + img.width + 8 > width_limit and x > 8:
            x = 8
            y += row_h + 30
            row_h = 0
        placed.append((img, x, y + 18, name))
        x += img.width + 12
        row_h = max(row_h, img.height + 18)
    total_w = max([p[0].width + p[1] for p in placed] + [200]) + 8
    total_h = y + row_h + 30
    canvas = Image.new("RGB", (total_w, total_h), (14, 15, 20))
    d = ImageDraw.Draw(canvas)
    for p in placed:
        canvas.paste(p[0], (p[1], p[2]))
        if len(p) == 4:
            d.text((p[1], p[2] - 17), p[3], fill=(225, 225, 235), font=f)
    path.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(path, format="PNG")


def segmentation_overview(sheet: SheetData, max_w: int = 1500) -> Image.Image:
    h, w = sheet.rgba.shape[:2]
    scale = min(1.0, max_w / w)
    small = Image.fromarray(over_checker(sheet.rgba).astype(np.uint8), "RGB")
    small = small.resize((round(w * scale), round(h * scale)), Image.LANCZOS)
    d = ImageDraw.Draw(small)
    f = font(14)
    for r, row in enumerate(sheet.boxes):
        for i, (x0, y0, x1, y1) in enumerate(row):
            d.rectangle([x0 * scale, y0 * scale, x1 * scale, y1 * scale], outline=(90, 220, 120))
            d.text((x0 * scale + 3, y0 * scale + 2), f"r{r}p{i}", fill=(255, 255, 120), font=f)
    return small


# --------------------------------------------------------------------------------------------
# sprites.json
# --------------------------------------------------------------------------------------------


def kind_entry(kind: str, kdef: dict) -> dict:
    cw, ch = kdef["cell"]
    align = kdef.get("align", "foot")
    radius = float(kdef.get("radius", 0))
    if align == "center":
        anchor = [cw / 2, ch / 2]
    elif kdef.get("prop"):
        anchor = [cw / 2, kdef.get("foot", ch - 1)]
    else:
        anchor = [cw / 2, kdef.get("foot", ch - 1) - radius]
    entry: dict = {"cell": [cw, ch], "anchor": anchor}
    if align != "center":
        entry["foot"] = kdef.get("foot", ch - 1)
    if radius:
        entry["radius"] = radius
    entry["mirror_side"] = bool(kdef.get("mirror_side", False))
    for key in ("prop", "texture", "rect_h", "variants", "centered"):
        if key in kdef:
            entry[key] = kdef[key]
    if align == "center":
        entry["centered"] = True
    return entry


def anim_record(out: OutputResult) -> dict:
    return {
        "file": f"{RES_PREFIX}{out.name}.png",
        "frames": len(out.frames),
        "fps": out.fps,
        "loop": out.loop,
    }


def owned_anims(manifest: dict, sheet: str) -> set[tuple[str, str]]:
    sdef = manifest["sheets"][sheet]
    if sdef.get("type") == "texture":
        return {(sdef["output"], "idle")}
    return {(o["kind"], o["anim"]) for row in sdef["rows"] for o in row["outputs"]}


def build_sprites_json(manifest: dict, existing: dict, results: list[OutputResult], textures: dict, done: list[str]) -> dict:
    """Rebuild the whole file from the manifest's kind definitions and the animations on hand."""
    store: dict[tuple[str, str], dict] = {}
    shadows: dict[str, list] = {}
    for kind, entry in existing.items():
        for anim, rec in entry.get("animations", {}).items():
            store[(kind, anim)] = rec
        if "shadow" in entry:
            shadows[kind] = entry["shadow"]
    for sheet in done:
        for key in owned_anims(manifest, sheet):
            store.pop(key, None)
    new_widths: dict[str, list[float]] = {}
    for out in results:
        store[(out.kind, out.anim)] = anim_record(out)
        new_widths.setdefault(out.kind, []).extend(out.shadow_widths)
    for name, size in textures.items():
        store[(name, "idle")] = {"file": f"{RES_PREFIX}{name}.png", "frames": 1, "fps": 1, "loop": True}
    for kind, widths in new_widths.items():
        if widths and manifest["kinds"][kind].get("shadow"):
            w = float(np.median(widths))
            shadows[kind] = [round(w), round(w * 0.34)]
    order = list(manifest["kinds"].keys())
    anim_order = {}
    for sdef in manifest["sheets"].values():
        if sdef.get("type") == "texture":
            continue
        for row in sdef["rows"]:
            for o in row["outputs"]:
                anim_order.setdefault(o["kind"], []).append(o["anim"])
    data: dict = {}
    for kind in order:
        kdef = manifest["kinds"][kind]
        anims = {a: r for (k, a), r in store.items() if k == kind}
        variants = kdef.get("variants")
        if variants and not anims:
            first = data.get(variants[0])
            if first is None:
                continue
            anims = dict(first["animations"])
        if not anims:
            continue
        entry = kind_entry(kind, kdef)
        if kind in shadows and kdef.get("shadow"):
            entry["shadow"] = shadows[kind]
        names = anim_order.get(kind, [])
        entry["animations"] = {a: anims[a] for a in names if a in anims}
        for a in anims:
            entry["animations"].setdefault(a, anims[a])
        data[kind] = entry
    return data


# --------------------------------------------------------------------------------------------
# driver
# --------------------------------------------------------------------------------------------


def cut_texture(name: str, sdef: dict, manifest: dict, source_dir: Path, out_dir: Path, proof_dir: Path):
    path = source_dir / f"{name}.png"
    if not path.exists():
        raise CutError(f"sheet {name}: source image missing ({path})")
    params = merged_params(manifest, sdef)
    size = int(sdef.get("size", 384))
    arr = make_texture(Image.open(path), size, float(sdef.get("blend", 0.2)), bool(sdef.get("variance_preserve", True)))
    write_png(out_dir / f"{sdef['output']}.png", arr, "RGB")
    tiled = np.tile(arr, (2, 2, 1))
    proof_dir.mkdir(parents=True, exist_ok=True)
    Image.fromarray(tiled, "RGB").save(proof_dir / f"{name}_proof.png")
    return sdef["output"], size, params


def cut_sheet(name: str, ctx: Context, out_dir: Path, proof_dir: Path) -> list[OutputResult]:
    sdef = ctx.manifest["sheets"][name]
    sheet = ctx.sheet(name)
    results: list[OutputResult] = []
    for r, row_def in enumerate(sdef["rows"]):
        for out_def in row_def["outputs"]:
            kdef = ctx.manifest["kinds"][out_def["kind"]]
            out = build_output(out_def, kdef, ctx, sheet, r)
            write_strip(out_dir / f"{out.name}.png", out.frames)
            for note in out.notes:
                print(f"  note: {out.name}: {note}")
            results.append(out)
    proof_for_outputs(sheet, results, proof_dir / f"{name}_proof.png")
    return results


def run(
    manifest: dict,
    source_dir: Path,
    out_dir: Path,
    proof_dir: Path,
    sheets: list[str] | None = None,
) -> tuple[list[str], list[str], list[str]]:
    """Cut `sheets` (default: every sheet whose source exists). Returns (done, missing, errors)."""
    explicit = bool(sheets)
    names = sheets or list(manifest["sheets"].keys())
    ctx = Context(manifest, source_dir)
    done: list[str] = []
    missing: list[str] = []
    errors: list[str] = []
    results: list[OutputResult] = []
    textures: dict[str, int] = {}
    for name in names:
        sdef = manifest["sheets"].get(name)
        if sdef is None:
            errors.append(f"sheet {name}: not in the manifest")
            continue
        if not (source_dir / f"{name}.png").exists():
            (errors if explicit else missing).append(
                f"sheet {name}: source image missing" if explicit else name
            )
            continue
        try:
            if sdef.get("type") == "texture":
                tex, size, _ = cut_texture(name, sdef, manifest, source_dir, out_dir, proof_dir)
                textures[tex] = size
            else:
                results += cut_sheet(name, ctx, out_dir, proof_dir)
            done.append(name)
            print(f"cut {name}")
        except CutError as exc:
            errors.append(str(exc))
    if done:
        path = out_dir / "sprites.json"
        existing = json.loads(path.read_text()) if path.exists() else {}
        data = build_sprites_json(manifest, existing, results, textures, done)
        for tex in textures:
            data[tex] = {
                "cell": [textures[tex], textures[tex]],
                "anchor": [textures[tex] / 2, textures[tex] / 2],
                "texture": True,
                "mirror_side": False,
                "animations": {"idle": {"file": f"{RES_PREFIX}{tex}.png", "frames": 1, "fps": 1, "loop": True}},
            }
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(data, indent=2) + "\n")
    return done, missing, errors


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("sheets", nargs="*", help="sheet names (default: every sheet with a source image)")
    ap.add_argument("--manifest", type=Path, default=DEFAULT_MANIFEST)
    ap.add_argument("--source", type=Path, default=DEFAULT_SOURCE)
    ap.add_argument("--out", type=Path, default=DEFAULT_OUT)
    ap.add_argument("--proofs", type=Path, default=None)
    args = ap.parse_args(argv)
    manifest = json.loads(args.manifest.read_text())
    proofs = args.proofs or (args.source / "proofs")
    done, missing, errors = run(manifest, args.source, args.out, proofs, args.sheets)
    if missing:
        print("no source image yet: " + ", ".join(missing))
    for err in errors:
        print(f"ERROR: {err}", file=sys.stderr)
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
