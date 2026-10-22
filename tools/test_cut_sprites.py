#!/usr/bin/env python3
"""Tests for tools/cut_sprites.py. Synthetic sheets, no real art needed.

    uv run --with pillow==12.3.0 --with numpy python tools/test_cut_sprites.py
"""

from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path

import numpy as np
from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
import cut_sprites as cut  # noqa: E402

KEY = np.array([255.0, 0.0, 255.0], np.float32)
MARKER = (200, 110, 40)
CELL = 96
FOOT = 88


def draw_figure(canvas: np.ndarray, cx: int, bottom: int, width: int, height: int, seed: int) -> None:
    """A soft-edged capsule with a colour gradient and an exact-colour marker patch inside."""
    top = bottom - height
    y0, y1 = max(0, top - 4), min(canvas.shape[0], bottom + 5)
    x0, x1 = max(0, cx - width), min(canvas.shape[1], cx + width)
    yy, xx = np.mgrid[y0:y1, x0:x1].astype(np.float32)
    r = width / 2.0
    cy = np.clip(yy, top + r, bottom - r)
    d = np.hypot(xx - cx, yy - cy) - r
    cov = np.clip(0.5 - d / 1.6, 0.0, 1.0)[..., None]
    t = ((yy - top) / height)[..., None]
    col = np.concatenate(
        [
            120 + 100 * t + 20 * np.sin((xx[..., None] + seed) * 0.31),
            110 + 70 * np.abs(np.sin(t * 5 + seed)) + 10 * np.cos(xx[..., None] * 0.2),
            40 + 90 * t * t + 15 * np.sin(yy[..., None] * 0.17),
        ],
        axis=2,
    )
    col = np.clip(col, 0, 255)
    my, mx = int(top + height * 0.45), cx
    col[my - y0 - 4 : my - y0 + 5, mx - x0 - 4 : mx - x0 + 5] = MARKER
    region = canvas[y0:y1, x0:x1]
    canvas[y0:y1, x0:x1] = cov * col + (1 - cov) * region


def blob(canvas: np.ndarray, cx: int, cy: int, radius: float, colour) -> None:
    yy, xx = np.mgrid[0 : canvas.shape[0], 0 : canvas.shape[1]].astype(np.float32)
    cov = np.clip(0.5 - (np.hypot(xx - cx, yy - cy) - radius) / 1.4, 0, 1)[..., None]
    canvas[:] = cov * np.array(colour, np.float32) + (1 - cov) * canvas


def make_sheet(path: Path, drift: float = 0.0) -> dict:
    """Two rows of poses (5 and 4), uneven gaps, different heights, speck + spark + noise island."""
    h, w = 520, 1100
    rng = np.random.default_rng(7)
    canvas = np.zeros((h, w, 3), np.float32) + (KEY + drift)
    row0 = [(110, 140), (270, 150), (470, 130), (640, 146), (900, 138)]
    row1 = [(150, 120), (330, 126), (610, 118), (880, 124)]
    truth = {"row0": [], "row1": []}
    for i, (cx, hh) in enumerate(row0):
        draw_figure(canvas, cx, 200, 40, hh, i)
        truth["row0"].append((cx, hh))
    for i, (cx, hh) in enumerate(row1):
        draw_figure(canvas, cx, 430, 40, hh, 10 + i)
        truth["row1"].append((cx, hh))
    blob(canvas, 640 + 20 + 14 + 6, 140, 6, (255, 220, 120))  # spark beside pose 3, 14 px gap
    canvas[300:303, 380:383] = (250, 250, 250)  # 3x3 speck between the rows' gaps
    canvas[100:106, 790:796] = (240, 240, 100)  # 36 px island, too far from any pose
    noisy = canvas + rng.normal(0, 3.0, canvas.shape)
    Image.fromarray(np.clip(np.rint(noisy), 0, 255).astype(np.uint8), "RGB").save(path)
    return truth


def mini_manifest(expected0: int = 5) -> dict:
    return {
        "defaults": {},
        "scale_groups": {"fig": {"measure": "height", "value": 70, "ref": [{"sheet": "s", "row": 0}]}},
        "kinds": {"fig": {"cell": [CELL, CELL], "foot": FOOT, "radius": 20, "mirror_side": True, "shadow": True}},
        "sheets": {
            "s": {
                "key": "magenta",
                "rows": [
                    {
                        "poses": expected0,
                        "outputs": [
                            {"file": "fig_a", "kind": "fig", "anim": "walk", "poses": [0, expected0],
                             "scale": "fig", "fps": 10, "loop": True, "shadow_src": True}
                        ],
                    },
                    {
                        "poses": 4,
                        "outputs": [
                            {"file": "fig_b", "kind": "fig", "anim": "run", "poses": [0, 4], "scale": "fig", "fps": 8}
                        ],
                    },
                ],
            }
        },
    }


class CutCase(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.tmp = tempfile.TemporaryDirectory()
        root = Path(cls.tmp.name)
        cls.src = root / "src"
        cls.src.mkdir()
        cls.truth = make_sheet(cls.src / "s.png")
        cls.manifest = mini_manifest()
        cls.out = root / "out"
        cls.proofs = root / "proofs"
        cls.done, cls.missing, cls.errors = cut.run(cls.manifest, cls.src, cls.out, cls.proofs)
        cls.ctx = cut.Context(cls.manifest, cls.src)

    @classmethod
    def tearDownClass(cls):
        cls.tmp.cleanup()

    def strip(self, name: str, cell: int = CELL) -> list[np.ndarray]:
        arr = np.asarray(Image.open(self.out / f"{name}.png").convert("RGBA"))
        self.assertEqual(arr.shape[0], cell, "strip height is the cell height")
        self.assertEqual(arr.shape[1] % cell, 0, "strip width is a whole number of cells")
        return [arr[:, i : i + cell] for i in range(0, arr.shape[1], cell)]

    def test_run_succeeds_and_writes_everything(self):
        self.assertEqual(self.errors, [])
        self.assertEqual(self.done, ["s"])
        for f in ("fig_a.png", "fig_b.png", "sprites.json"):
            self.assertTrue((self.out / f).exists(), f)
        self.assertTrue((self.proofs / "s_proof.png").exists())

    def test_pose_count_with_uneven_spacing(self):
        rows = self.ctx.sheet("s").rows
        self.assertEqual([len(r) for r in rows], [5, 4])
        # poses come out left to right and match the drawn heights (spark and speck do not leak)
        for pose, (_, hh) in zip(rows[0], self.truth["row0"]):
            self.assertAlmostEqual(pose.height, hh + 1, delta=3)
        xs = [p.origin[0] for p in rows[0]]
        self.assertEqual(xs, sorted(xs))

    def test_spark_merged_noise_dropped(self):
        pose3 = self.ctx.sheet("s").rows[0][3]
        # the spark sits 20+14+6 px right of the pose centre: merged into pose 3's crop
        self.assertGreater(pose3.width, 40 + 14)
        for row in self.ctx.sheet("s").rows:
            for pose in row:  # the 6x6 island and the speck are in no pose
                self.assertLess(pose.width, 90)

    def test_alpha_is_continuous_not_thresholded(self):
        frames = self.strip("fig_a")
        alpha = np.concatenate([f[..., 3].ravel() for f in frames])
        self.assertGreater(len(np.unique(alpha)), 100)
        partial = ((alpha > 8) & (alpha < 247)).sum()
        self.assertGreater(partial, 400)
        self.assertEqual(alpha.min(), 0)
        self.assertEqual(alpha.max(), 255)

    def test_no_palette_quantization(self):
        frame = self.strip("fig_a")[1]
        opaque = frame[frame[..., 3] == 255][:, :3]
        colours = len({tuple(c) for c in opaque})
        self.assertGreater(colours, 600, "painterly gradients survive")

    def test_edge_has_no_key_tint(self):
        for frame in self.strip("fig_a"):
            a = frame[..., 3].astype(np.float32) / 255.0
            rgb = frame[..., :3].astype(np.float32)
            edge = (a > 0.1) & (a < 0.9)
            self.assertGreater(edge.sum(), 50)
            # figure colours have green > min(red, blue) never; magenta spill would flip that
            tint = np.minimum(rgb[..., 0], rgb[..., 2]) - rgb[..., 1]
            interior = a > 0.99
            self.assertLess(tint[edge].mean(), tint[interior].mean() + 25.0)

    def test_one_scale_for_all_frames(self):
        rows = self.ctx.sheet("s").rows[0]
        ratios = []
        for pose, frame in zip(rows, self.strip("fig_a")):
            box = cut.alpha_bbox(frame[..., 3].astype(np.float32) / 255.0, 0.1)
            ratios.append((box[3] - box[1]) / pose.height)
        self.assertLess(max(ratios) - min(ratios), 0.03, ratios)
        factor = 70 / max(p.height for p in rows)
        for r in ratios:
            self.assertAlmostEqual(r, factor, delta=0.03)
        # row 1 uses the same group: same factor even though its poses are shorter
        ratios_b = []
        for pose, frame in zip(self.ctx.sheet("s").rows[1], self.strip("fig_b")):
            box = cut.alpha_bbox(frame[..., 3].astype(np.float32) / 255.0, 0.1)
            ratios_b.append((box[3] - box[1]) / pose.height)
        for r in ratios_b:
            self.assertAlmostEqual(r, factor, delta=0.03)

    def test_feet_land_on_the_foot_row(self):
        for name in ("fig_a", "fig_b"):
            for frame in self.strip(name):
                rows = np.flatnonzero((frame[..., 3] / 255.0 > 0.1).any(axis=1))
                self.assertEqual(int(rows[-1]), FOOT)

    def test_body_is_centred(self):
        for frame in self.strip("fig_a"):
            a = frame[..., 3].astype(np.float32)
            mid = int((np.flatnonzero((a / 255 > 0.1).any(axis=1))[[0, -1]]).mean())
            low = a[mid:]
            cx = (low.sum(axis=0) * (np.arange(CELL) + 0.5)).sum() / low.sum()
            self.assertAlmostEqual(cx, CELL / 2, delta=1.5)

    def test_interior_pixels_are_untouched_by_despill(self):
        rgb = np.asarray(Image.open(self.src / "s.png").convert("RGB"), dtype=np.float32)
        key = cut.estimate_key(rgb, 16)
        out, alpha = cut.matte(rgb, key, cut.DEFAULTS, "magenta")
        cx, hh = self.truth["row0"][1]
        py, px = int(200 - hh + hh * 0.45), cx  # centre of the exact-colour marker patch
        self.assertEqual(alpha[py, px], 1.0)
        np.testing.assert_array_equal(out[py, px], rgb[py, px])
        core = alpha >= 0.999
        interior = cut.erode3(cut.erode3(core))
        self.assertGreater(interior.sum(), 5000)
        np.testing.assert_array_equal(out[interior], rgb[interior])

    def test_key_estimated_from_the_border_when_it_drifts(self):
        root = Path(self.tmp.name) / "drift"
        root.mkdir()
        make_sheet(root / "s.png", drift=-18.0)  # key is (237, -18->0, 237)
        done, _, errors = cut.run(self.manifest, root, root / "out", root / "proofs")
        self.assertEqual(errors, [])
        frame = np.asarray(Image.open(root / "out" / "fig_a.png").convert("RGBA"))[:, :CELL]
        self.assertEqual(int(np.flatnonzero((frame[..., 3] > 25).any(axis=1))[-1]), FOOT)

    def test_pose_count_mismatch_is_an_error(self):
        bad = mini_manifest(expected0=6)
        done, _, errors = cut.run(bad, self.src, Path(self.tmp.name) / "bad", Path(self.tmp.name) / "badp")
        self.assertEqual(done, [])
        self.assertEqual(len(errors), 1)
        self.assertIn("sheet s row 0", errors[0])
        self.assertIn("found 5", errors[0])
        self.assertIn("expected 6", errors[0])
        # the CLI turns it into a non-zero exit code
        manifest_path = Path(self.tmp.name) / "bad.json"
        manifest_path.write_text(__import__("json").dumps(bad))
        code = cut.main(
            ["--manifest", str(manifest_path), "--source", str(self.src), "--out", str(Path(self.tmp.name) / "bad2")]
        )
        self.assertEqual(code, 1)

    def test_output_is_deterministic(self):
        root = Path(self.tmp.name) / "again"
        cut.run(self.manifest, self.src, root / "out", root / "proofs")
        for name in ("fig_a.png", "fig_b.png", "sprites.json"):
            self.assertEqual((root / "out" / name).read_bytes(), (self.out / name).read_bytes(), name)

    def test_sprites_json_follows_the_contract(self):
        import json

        data = json.loads((self.out / "sprites.json").read_text())
        fig = data["fig"]
        self.assertEqual(fig["cell"], [CELL, CELL])
        self.assertEqual(fig["anchor"], [CELL / 2, FOOT - 20])
        self.assertTrue(fig["mirror_side"])
        self.assertEqual(fig["animations"]["walk"]["frames"], 5)
        self.assertEqual(fig["animations"]["walk"]["file"], "res://assets/sprites/fig_a.png")
        self.assertEqual(fig["animations"]["run"]["fps"], 8.0)
        self.assertIn("shadow", fig)


class CentredCase(unittest.TestCase):
    def test_explosion_style_strip_shares_one_centre(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            canvas = np.zeros((300, 1200, 3), np.float32) + KEY
            centres = [(130, 140), (330, 150), (560, 135), (800, 160), (1010, 142)]
            for i, (cx, cy) in enumerate(centres):
                blob(canvas, cx, cy, 20 + 14 * i, (250, 160 - 20 * i, 40 + 10 * i))
            Image.fromarray(np.clip(canvas, 0, 255).astype(np.uint8), "RGB").save(root / "fx.png")
            manifest = {
                "defaults": {},
                "scale_groups": {"fx": {"measure": "extent", "value": 150, "ref": [{"sheet": "fx", "row": 0}]}},
                "kinds": {"fx": {"cell": [192, 192], "align": "center"}},
                "sheets": {
                    "fx": {
                        "key": "magenta",
                        "rows": [
                            {"poses": 5, "outputs": [{"file": "fx_burst", "kind": "fx", "anim": "burst",
                                                       "poses": [0, 5], "scale": "fx", "fps": 12, "loop": False}]}
                        ],
                    }
                },
            }
            done, _, errors = cut.run(manifest, root, root / "out", root / "proofs")
            self.assertEqual(errors, [])
            arr = np.asarray(Image.open(root / "out" / "fx_burst.png").convert("RGBA")).astype(np.float32)
            for i in range(5):
                frame = arr[:, i * 192 : (i + 1) * 192]
                a = frame[..., 3]
                cx = (a.sum(axis=0) * (np.arange(192) + 0.5)).sum() / a.sum()
                cy = (a.sum(axis=1) * (np.arange(192) + 0.5)).sum() / a.sum()
                self.assertAlmostEqual(cx, 96, delta=1.0)
                self.assertAlmostEqual(cy, 96, delta=1.0)


class SegmentationModes(unittest.TestCase):
    def _sheet(self, root: Path) -> None:
        canvas = np.zeros((400, 600, 3), np.float32) + KEY
        blob(canvas, 200, 250, 60, (150, 110, 170))  # A
        blob(canvas, 265, 170, 30, (250, 220, 40))  # B: its x range overlaps A's, no gap in x
        canvas += np.random.default_rng(1).normal(0, 2.0, canvas.shape)
        Image.fromarray(np.clip(canvas, 0, 255).astype(np.uint8), "RGB").save(root / "ov.png")

    def _manifest(self, split: str, skip_second_row: bool = False) -> dict:
        rows = [{"poses": 2, "params": {"split": split},
                 "outputs": [{"file": "ov_a", "kind": "k", "anim": "idle", "poses": [0, 2],
                              "scale": {"measure": "height", "value": 60}}]}]
        return {"defaults": {}, "scale_groups": {}, "kinds": {"k": {"cell": [96, 96], "foot": 88}},
                "sheets": {"ov": {"key": "magenta", "rows": rows}}}

    def test_overlapping_x_ranges_need_component_split(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            self._sheet(root)
            _, _, errors = cut.run(self._manifest("gaps"), root, root / "o1", root / "p1")
            self.assertTrue(errors and "found 1 poses, expected 2" in errors[0], errors)
            done, _, errors = cut.run(self._manifest("components"), root, root / "o2", root / "p2")
            self.assertEqual((done, errors), (["ov"], []))
            ctx = cut.Context(self._manifest("components"), root)
            a, b = ctx.sheet("ov").rows[0]
                        # (255, 195) is B's pixel inside A's box: erased from A's crop, present in B's
            self.assertEqual(a.rgba[195 - a.origin[1], 255 - a.origin[0], 3], 0.0)
            self.assertGreater(b.rgba[195 - b.origin[1], 255 - b.origin[0], 3], 0.9)

    def test_skipped_row_is_not_cut_and_not_counted(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            canvas = np.zeros((400, 600, 3), np.float32) + KEY
            draw_figure(canvas, 150, 150, 40, 100, 1)
            draw_figure(canvas, 300, 150, 40, 90, 2)
            draw_figure(canvas, 200, 350, 40, 100, 3)  # rejected row: 1 pose drawn, 5 "expected"
            Image.fromarray(np.clip(canvas, 0, 255).astype(np.uint8), "RGB").save(root / "sk.png")
            manifest = {
                "defaults": {}, "scale_groups": {}, "kinds": {"k": {"cell": [96, 96], "foot": 88}},
                "sheets": {"sk": {"key": "magenta", "rows": [
                    {"poses": 2, "outputs": [{"file": "sk_a", "kind": "k", "anim": "idle", "poses": [0, 2],
                                              "scale": {"measure": "height", "value": 60}}]},
                    {"poses": 5, "skip": True, "outputs": []}]}},
            }
            done, _, errors = cut.run(manifest, root, root / "out", root / "proofs")
            self.assertEqual((done, errors), (["sk"], []))
            self.assertFalse((root / "out" / "sk_b.png").exists())
            self.assertEqual(Image.open(root / "out" / "sk_a.png").size, (192, 96))


class BodyHeight(unittest.TestCase):
    def test_thin_pole_does_not_count_toward_the_figure_height(self):
        canvas = np.zeros((300, 200, 3), np.float32) + KEY
        draw_figure(canvas, 100, 250, 40, 100, 1)
        canvas[110:160, 128:131] = (180, 150, 60)  # a 3 px pole sticking up beside the head
        rgb, alpha = cut.matte(canvas, KEY, cut.DEFAULTS, "magenta")
        rgba = np.concatenate([rgb, alpha[..., None]], axis=2)
        box = cut.alpha_bbox(alpha, 0.1)
        pose = cut.Pose("t", 0, 0, rgba, (0, 0), box)
        self.assertGreaterEqual(pose.height, 135)
        self.assertAlmostEqual(cut.body_height(pose, 0.08, 0.1), 100, delta=3)


class TextureCase(unittest.TestCase):
    def test_texture_tiles_seamlessly(self):
        rng = np.random.default_rng(3)
        n = 512
        yy, xx = np.mgrid[0:n, 0:n].astype(np.float32)
        # smooth, NON-periodic content (a drifting gradient) plus fine noise: raw edges differ a lot
        base = 80 + 0.18 * xx + 0.12 * yy + 20 * np.sin(xx * 0.021 + yy * 0.013)
        img = np.stack([base, base * 0.8 + 10, 90 + 0.1 * xx], axis=2) + rng.normal(0, 4, (n, n, 3))
        src = Image.fromarray(np.clip(img, 0, 255).astype(np.uint8), "RGB")
        out = cut.make_texture(src, 192, 0.2, True).astype(np.float32)
        raw = np.asarray(src.resize((192, 192), Image.LANCZOS), dtype=np.float32)

        def seam(a):
            lr = np.abs(a[:, 0] - a[:, -1]).mean()
            tb = np.abs(a[0] - a[-1]).mean()
            return lr, tb

        inner_x = np.abs(out[:, 96] - out[:, 97]).mean()
        inner_y = np.abs(out[96] - out[97]).mean()
        lr, tb = seam(out)
        raw_lr, raw_tb = seam(raw)
        self.assertGreater(raw_lr, 30.0, "the test image really is not tileable")
        self.assertLess(lr, inner_x + 4.0)
        self.assertLess(tb, inner_y + 4.0)
        self.assertLess(lr, raw_lr / 4)
        self.assertLess(tb, raw_tb / 4)
        self.assertEqual(out.shape, (192, 192, 3))

    def test_texture_sheet_is_written_opaque(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            rng = np.random.default_rng(5)
            Image.fromarray(rng.integers(0, 255, (256, 256, 3), dtype=np.uint8), "RGB").save(root / "tex_t.png")
            manifest = {
                "defaults": {}, "scale_groups": {}, "kinds": {"ground_t": {"cell": [96, 96], "align": "center", "texture": True}},
                "sheets": {"tex_t": {"type": "texture", "output": "ground_t", "size": 96}},
            }
            done, _, errors = cut.run(manifest, root, root / "out", root / "proofs")
            self.assertEqual((done, errors), (["tex_t"], []))
            img = Image.open(root / "out" / "ground_t.png")
            self.assertEqual(img.size, (96, 96))
            self.assertEqual(img.mode, "RGB")


if __name__ == "__main__":
    unittest.main(verbosity=2)
