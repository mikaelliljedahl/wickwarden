#!/usr/bin/env python3
"""Synthesise every sound of Wickwarden. Standard library only (no numpy).

    python3 tools/make_audio.py              # build everything, then print the check table
    python3 tools/make_audio.py sfx          # only the sound effects
    python3 tools/make_audio.py music        # only the music loops
    python3 tools/make_audio.py --check      # only analyse the files that exist
    python3 tools/make_audio.py swing cave   # named items

All audio is generated here from oscillators, filtered noise, envelopes, pitch sweeps, delay and
reverb. There are no samples and no downloads (docs/audio-provenance.md). Output is reproducible:
every item uses its own fixed random seed.

    assets/audio/sfx/<name>.wav       16-bit mono 44.1 kHz, peak -3 dBFS
    assets/audio/music/<name>.ogg     Vorbis (ffmpeg libvorbis, q 4), seamless loop

The music is synthesised at 22.05 kHz (warm, soft, 4x cheaper) and upsampled to 44.1 kHz. Loops are
made seamless by rendering circularly: notes and drones wrap around the loop end, and the reverb
and master filters run over two copies of the loop so the tail of the last bar flows into the first.
"""

from __future__ import annotations

import array
import math
import random
import re
import subprocess
import sys
import tempfile
import wave
import zlib
from multiprocessing import Pool
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SFX_DIR = ROOT / "assets" / "audio" / "sfx"
MUSIC_DIR = ROOT / "assets" / "audio" / "music"
SR = 44100
MUSIC_SR = 22050
PEAK = 10 ** (-3 / 20)  # -3 dBFS
TAU = 2 * math.pi
OGG_QUALITY = "4"

# ---------------------------------------------------------------------------------------------
# DSP helpers (lists of floats)
# ---------------------------------------------------------------------------------------------


def secs(t: float, sr: int = SR) -> int:
    return int(round(t * sr))


def noise(n: int, rng: random.Random) -> list[float]:
    return [rng.uniform(-1.0, 1.0) for _ in range(n)]


def add_into(dst: list[float], src: list[float], start: float = 0.0, gain: float = 1.0, sr: int = SR) -> None:
    s = secs(start, sr)
    end = min(len(dst), s + len(src))
    for i in range(max(0, s), end):
        dst[i] += src[i - s] * gain


def add_wrap(dst: list[float], src: list[float], start_sec: float, gain: float, sr: int) -> None:
    length = len(dst)
    s = secs(start_sec, sr) % length
    for i, v in enumerate(src):
        dst[(s + i) % length] += v * gain


def mul(a: list[float], b: list[float]) -> list[float]:
    return [x * y for x, y in zip(a, b)]


def scale(a: list[float], g: float) -> list[float]:
    return [x * g for x in a]


def exp_env(n: int, tau: float, sr: int = SR) -> list[float]:
    k = 1.0 / (tau * sr)
    return [math.exp(-i * k) for i in range(n)]


def attack_env(n: int, attack: float, sr: int = SR) -> list[float]:
    a = max(1, secs(attack, sr))
    return [min(1.0, i / a) for i in range(n)]


def hump(n: int) -> list[float]:
    """Smooth 0 -> 1 -> 0 bell (sin^2) over n samples."""
    return [math.sin(math.pi * i / max(1, n - 1)) ** 2 for i in range(n)]


def perc(n: int, tau: float, attack: float = 0.002, sr: int = SR) -> list[float]:
    """Percussive envelope: short linear attack then exponential decay."""
    return mul(attack_env(n, attack, sr), exp_env(n, tau, sr))


def exp_sweep(f0: float, f1: float, dur: float):
    ratio = f1 / f0
    return lambda t: f0 * ratio ** min(1.0, t / dur)


def lin_sweep(f0: float, f1: float, dur: float):
    return lambda t: f0 + (f1 - f0) * min(1.0, t / dur)


def osc(n: int, f, harm=((1, 1.0),), sr: int = SR, phase: float = 0.0, vib=None) -> list[float]:
    """Phase-accumulating oscillator. `f` is a number or a function of time in seconds. `harm` is
    ((multiple, amplitude), ...). `vib` is (rate Hz, depth in semitones)."""
    out = [0.0] * n
    ph = phase
    sin = math.sin
    single = len(harm) == 1 and harm[0][0] == 1
    amp0 = harm[0][1]
    for i in range(n):
        t = i / sr
        fr = f(t) if callable(f) else f
        if vib is not None:
            fr *= 2 ** (vib[1] * math.sin(TAU * vib[0] * t) / 12.0)
        ph += TAU * fr / sr
        if single:
            out[i] = amp0 * sin(ph)
        else:
            s = 0.0
            for m, a in harm:
                s += a * sin(ph * m)
            out[i] = s
    return out


def coefs(kind: str, fc: float, q: float, sr: int):
    fc = min(max(fc, 10.0), sr * 0.45)
    w = TAU * fc / sr
    cw, sw = math.cos(w), math.sin(w)
    alpha = sw / (2 * q)
    if kind == "lp":
        b0 = (1 - cw) / 2
        b1 = 1 - cw
        b2 = b0
    elif kind == "hp":
        b0 = (1 + cw) / 2
        b1 = -(1 + cw)
        b2 = b0
    else:  # bp, constant 0 dB peak
        b0 = alpha
        b1 = 0.0
        b2 = -alpha
    a0 = 1 + alpha
    return b0 / a0, b1 / a0, b2 / a0, -2 * cw / a0, (1 - alpha) / a0


def biquad(x: list[float], kind: str, fc: float, q: float = 0.707, sr: int = SR) -> list[float]:
    b0, b1, b2, a1, a2 = coefs(kind, fc, q, sr)
    x1 = x2 = y1 = y2 = 0.0
    out = [0.0] * len(x)
    for i, v in enumerate(x):
        y = b0 * v + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2
        x2 = x1
        x1 = v
        y2 = y1
        y1 = y
        out[i] = y
    return out


def biquad_sweep(x: list[float], kind: str, fc_fn, q: float = 0.9, sr: int = SR, step: int = 16) -> list[float]:
    """Biquad whose cutoff follows fc_fn(t seconds); coefficients are refreshed every `step` samples."""
    x1 = x2 = y1 = y2 = 0.0
    out = [0.0] * len(x)
    b0 = b1 = b2 = a1 = a2 = 0.0
    for i, v in enumerate(x):
        if i % step == 0:
            b0, b1, b2, a1, a2 = coefs(kind, fc_fn(i / sr), q, sr)
        y = b0 * v + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2
        x2 = x1
        x1 = v
        y2 = y1
        y1 = y
        out[i] = y
    return out


def sat(x: list[float], drive: float = 1.5) -> list[float]:
    tanh = math.tanh
    return [tanh(v * drive) for v in x]


def comb(x: list[float], delay: int, fb: float, damp: float) -> list[float]:
    buf = [0.0] * delay
    idx = 0
    lp = 0.0
    out = [0.0] * len(x)
    for i, v in enumerate(x):
        d = buf[idx]
        lp = d * (1.0 - damp) + lp * damp
        buf[idx] = v + lp * fb
        out[i] = d
        idx += 1
        if idx == delay:
            idx = 0
    return out


def allpass(x: list[float], delay: int, g: float) -> list[float]:
    buf = [0.0] * delay
    idx = 0
    out = [0.0] * len(x)
    for i, v in enumerate(x):
        d = buf[idx]
        out[i] = d - g * v
        buf[idx] = v + g * d
        idx += 1
        if idx == delay:
            idx = 0
    return out


def reverb(x: list[float], sr: int, rt60: float = 1.5, wet: float = 0.25, damp: float = 0.35, combs: int = 5) -> list[float]:
    """Schroeder/Freeverb style: parallel damped combs into three series allpasses."""
    k = sr / 44100.0
    acc = [0.0] * len(x)
    for d in (1116, 1188, 1277, 1356, 1422, 1491)[:combs]:
        dl = max(8, int(d * k))
        fb = 10 ** (-3.0 * dl / sr / rt60)
        c = comb(x, dl, fb, damp)
        acc = [a + b for a, b in zip(acc, c)]
    g = 1.0 / combs
    acc = [a * g for a in acc]
    for d in (556, 441, 341):
        acc = allpass(acc, max(8, int(d * k)), 0.5)
    return [dry + wet * w for dry, w in zip(x, acc)]


def echo(x: list[float], delay_s: float, fb: float, mix: float, taps: int, sr: int = SR, damp: float = 0.4) -> list[float]:
    """Feedback delay with a darkening filter; the tail is added to the dry signal."""
    d = secs(delay_s, sr)
    out = list(x) + [0.0] * (d * taps)
    prev = list(x)
    for t in range(1, taps + 1):
        lp = 0.0
        nxt = []
        for v in prev:
            lp = lp * damp + v * (1 - damp)
            nxt.append(lp * fb)
        prev = nxt
        for i, v in enumerate(prev):
            out[i + d * t] += v * mix
    return out


def remove_dc(x: list[float]) -> list[float]:
    m = sum(x) / len(x)
    return [v - m for v in x]


def fade(x: list[float], fin: float, fout: float, sr: int = SR) -> list[float]:
    n = len(x)
    a = min(n, secs(fin, sr))
    b = min(n, secs(fout, sr))
    for i in range(a):
        x[i] *= 0.5 - 0.5 * math.cos(math.pi * i / a)
    for i in range(b):
        x[n - 1 - i] *= 0.5 - 0.5 * math.cos(math.pi * i / b)
    return x


def normalise(x: list[float], peak: float = PEAK) -> list[float]:
    m = max(abs(v) for v in x)
    if m <= 0.0:
        raise ValueError("silent signal")
    g = peak / m
    return [v * g for v in x]


def finite(x: list[float], name: str) -> None:
    for v in x:
        if not math.isfinite(v):
            raise ValueError(f"{name}: non-finite sample")


def hz(name: str) -> float:
    m = re.fullmatch(r"([A-G])(b|#)?(-?\d)", name)
    if not m:
        raise ValueError(f"bad note {name}")
    semis = {"C": 0, "D": 2, "E": 4, "F": 5, "G": 7, "A": 9, "B": 11}[m.group(1)]
    semis += {"b": -1, "#": 1, None: 0}[m.group(2)]
    midi = 12 * (int(m.group(3)) + 1) + semis
    return 440.0 * 2 ** ((midi - 69) / 12.0)


def cents(f: float, c: float) -> float:
    return f * 2 ** (c / 1200.0)


def seed_of(name: str) -> int:
    return zlib.crc32(name.encode()) ^ 0x5EED


# ---------------------------------------------------------------------------------------------
# Instruments
# ---------------------------------------------------------------------------------------------


def pluck(freq: float, dur: float, sr: int, rng: random.Random, t60: float = 1.5, pos: float = 0.3, bright: float = 0.55) -> list[float]:
    """Karplus-Strong string with a tuning allpass: a warm plucked string, peak about 1."""
    n = int(dur * sr)
    total = sr / freq - 0.5
    length = int(total)
    frac = total - length
    if frac < 0.2:
        length -= 1
        frac += 1.0
    a = (1.0 - frac) / (1.0 + frac)
    buf = [rng.uniform(-1.0, 1.0) for _ in range(length)]
    prev = 0.0
    for i in range(length):  # soften the excitation
        prev += bright * (buf[i] - prev)
        buf[i] = prev
    p = max(1, int(pos * length))
    buf = [buf[i] - buf[i - p] for i in range(length)]  # pluck position comb
    m = sum(buf) / length
    buf = [v - m for v in buf]
    decay = 10 ** (-3.0 / (t60 * freq))
    out = [0.0] * n
    idx = 0
    prev_y = 0.0
    apx = apy = 0.0
    for i in range(n):
        y = buf[idx]
        f = decay * 0.5 * (y + prev_y)
        prev_y = y
        ap = a * f + apx - a * apy
        apx = f
        apy = ap
        buf[idx] = ap
        out[i] = y
        idx += 1
        if idx == length:
            idx = 0
    peak = max(abs(v) for v in out[: max(1, int(0.2 * sr))]) or 1.0
    out = [v / peak for v in out]
    return fade(out, 0.001, min(0.05, dur * 0.2), sr)


def mallet(freq: float, dur: float, sr: int, ratios=(1.0, 3.98, 10.1), amps=(1.0, 0.25, 0.06), taus=(0.9, 0.16, 0.05)) -> list[float]:
    """Soft marimba-like bar: a fundamental plus fast-dying overtones."""
    n = int(dur * sr)
    out = [0.0] * n
    sin = math.sin
    for r, a, tau in zip(ratios, amps, taus):
        w = TAU * freq * r / sr
        k = 1.0 / (tau * sr)
        if freq * r > sr * 0.45:
            continue
        for i in range(n):
            out[i] += a * sin(w * i) * math.exp(-i * k)
    for i in range(min(n, secs(0.004, sr))):
        out[i] *= i / secs(0.004, sr)
    return fade(out, 0.0, min(0.06, dur * 0.2), sr)


def bell(freq: float, dur: float, sr: int, tau: float = 2.5) -> list[float]:
    """Inharmonic chime: partials at bell-like ratios, higher ones die sooner."""
    n = int(dur * sr)
    out = [0.0] * n
    sin = math.sin
    for r, a, t in ((1.0, 1.0, 1.0), (2.0, 0.45, 0.65), (2.76, 0.35, 0.45), (5.4, 0.14, 0.25), (8.93, 0.06, 0.15)):
        if freq * r > sr * 0.45:
            continue
        w = TAU * freq * r / sr
        k = 1.0 / (tau * t * sr)
        for i in range(n):
            out[i] += a * sin(w * i) * math.exp(-i * k)
    for i in range(min(n, secs(0.006, sr))):
        out[i] *= i / secs(0.006, sr)
    return fade(out, 0.0, min(0.1, dur * 0.2), sr)


def pad_chord(freqs, dur: float, sr: int, attack: float, release: float) -> list[float]:
    """Slow soft pad: detuned voices with three harmonics, lowpassed, long fades."""
    n = int(dur * sr)
    out = [0.0] * n
    sin = math.sin
    for f in freqs:
        for c, g in ((-6.0, 1.0), (6.0, 1.0), (0.0, 0.7)):
            w = TAU * cents(f, c) / sr
            for i in range(n):
                p = w * i
                out[i] += g * (sin(p) + 0.33 * sin(2 * p) + 0.12 * sin(3 * p))
    na, nr = secs(attack, sr), secs(release, sr)
    for i in range(n):
        e = 1.0
        if i < na:
            e = math.sin(0.5 * math.pi * i / na) ** 2
        if i >= n - nr:
            e = min(e, math.sin(0.5 * math.pi * (n - 1 - i) / nr) ** 2)
        out[i] *= e
    return biquad(out, "lp", 1500.0, 0.6, sr)


# ---------------------------------------------------------------------------------------------
# Sound effects
# ---------------------------------------------------------------------------------------------


def sfx_swing(rng):
    n = secs(0.30)
    w = biquad_sweep(noise(n, rng), "bp", exp_sweep(450, 2400, 0.22), 1.3)
    w = mul(w, [math.sin(math.pi * min(1.0, i / secs(0.26))) ** 1.5 for i in range(n)])
    low = mul(osc(n, exp_sweep(150, 80, 0.2)), perc(n, 0.07))
    return [a * 1.0 + b * 0.25 for a, b in zip(w, low)]


def sfx_charge_start(rng):
    n = secs(0.8)
    tone = osc(n, exp_sweep(150, 260, 0.7), ((1, 1.0), (2, 0.3), (3, 0.1)))
    trem = [0.75 + 0.25 * math.sin(TAU * 7.0 * i / SR) for i in range(n)]
    env = mul(attack_env(n, 0.25), [min(1.0, (n - i) / secs(0.2)) for i in range(n)])
    air = biquad(noise(n, rng), "bp", 1500, 1.5)
    out = [t * m * e + 0.08 * a * e for t, m, e, a in zip(tone, trem, env, air)]
    return biquad(out, "lp", 2500)


def sfx_charge_ready(rng):
    n = secs(0.5)
    out = [0.0] * n
    for off, f in ((0.0, 880.0), (0.07, 1318.5)):
        t = osc(n - secs(off), f, ((1, 1.0), (2, 0.3), (3.01, 0.12)))
        add_into(out, mul(t, perc(len(t), 0.13)), off, 1.0)
    return out


def sfx_flare(rng):
    n = secs(1.0)
    out = [0.0] * n
    crack = biquad(noise(n, rng), "hp", 1800)
    add_into(out, mul(crack, perc(n, 0.035, 0.001)), 0.0, 0.7)
    rise = osc(n, exp_sweep(250, 1500, 0.28), ((1, 1.0), (2, 0.4), (3, 0.2)))
    add_into(out, mul(rise, mul(attack_env(n, 0.01), exp_env(n, 0.22))), 0.0, 0.6)
    for off, f in ((0.12, 1760.0), (0.2, 2637.0)):
        m = n - secs(off)
        add_into(out, mul(osc(m, f), perc(m, 0.2)), off, 0.28)
    hum = osc(n, 110.0, ((1, 1.0), (2, 0.5)))
    add_into(out, mul(hum, perc(n, 0.3)), 0.0, 0.3)
    return reverb(sat(out, 1.2), SR, 0.7, 0.2)


def sfx_hook_hit(rng):
    n = secs(0.25)
    thump = mul(osc(n, exp_sweep(230, 85, 0.1)), perc(n, 0.06))
    ping = mul(osc(n, 1180.0, ((1, 1.0), (1.62, 0.5))), perc(n, 0.07))
    click = mul(biquad(noise(n, rng), "hp", 3000), perc(n, 0.006, 0.0005))
    return [a + 0.35 * b + 0.3 * c for a, b, c in zip(thump, ping, click)]


def sfx_hook_clank(rng):
    n = secs(0.6)
    out = [0.0] * n
    for r, a, tau in ((1.0, 1.0, 0.3), (2.32, 0.6, 0.2), (4.1, 0.4, 0.12), (6.3, 0.2, 0.08)):
        add_into(out, mul(osc(n, 640.0 * r), perc(n, tau, 0.001)), 0.0, a)
    click = mul(biquad(noise(n, rng), "hp", 4000), perc(n, 0.005, 0.0005))
    return [a + 0.6 * c for a, c in zip(out, click)]


def sfx_bush_cut(rng):
    n = secs(0.35)
    wobble = biquad(noise(n, rng), "lp", 30)
    m = max(abs(v) for v in wobble)
    wobble = [0.6 + 0.4 * v / m for v in wobble]
    leaf = mul(biquad(noise(n, rng), "bp", 3200, 0.8), mul(wobble, perc(n, 0.09, 0.003)))
    swish = mul(biquad_sweep(noise(n, rng), "bp", exp_sweep(1800, 900, 0.2), 0.9), perc(n, 0.06, 0.004))
    return [a + 0.8 * b for a, b in zip(leaf, swish)]


def sfx_ward_block(rng):
    n = secs(0.45)
    out = [0.0] * n
    for r, a, tau in ((1.0, 1.0, 0.16), (2.76, 0.5, 0.1), (5.4, 0.2, 0.06)):
        add_into(out, mul(osc(n, 330.0 * r), perc(n, tau, 0.001)), 0.0, a)
    thump = mul(osc(n, exp_sweep(140, 70, 0.08)), perc(n, 0.05))
    out = [a + 0.8 * b for a, b in zip(out, thump)]
    return biquad(out, "lp", 3200)


def sfx_moth_launch(rng):
    n = secs(0.5)
    flap = [0.55 + 0.45 * math.sin(TAU * 38.0 * i / SR) for i in range(n)]
    tone = osc(n, exp_sweep(420, 760, 0.35), ((1, 1.0), (2, 0.2)))
    env = [math.sin(math.pi * min(1.0, i / n)) ** 1.2 for i in range(n)]
    dust = biquad(noise(n, rng), "bp", 2600, 1.2)
    return [(t * 0.7 + d * 0.25) * f * e for t, d, f, e in zip(tone, dust, flap, env)]


def sfx_pot_place(rng):
    n = secs(0.25)
    thunk = mul(osc(n, exp_sweep(150, 80, 0.08)), perc(n, 0.07))
    scuff = mul(biquad(noise(n, rng), "lp", 700), perc(n, 0.025, 0.001))
    return [a + 0.5 * b for a, b in zip(thunk, scuff)]


def sfx_pot_explode(rng):
    n = secs(1.5)
    out = [0.0] * n
    rumble = biquad_sweep(noise(n, rng), "lp", exp_sweep(2600, 160, 0.9), 0.8)
    add_into(out, mul(rumble, perc(n, 0.38, 0.003)), 0.0, 1.0)
    sub = osc(n, exp_sweep(95, 32, 0.6))
    add_into(out, mul(sub, perc(n, 0.45, 0.004)), 0.0, 1.0)
    crack = biquad(noise(n, rng), "hp", 1200)
    add_into(out, mul(crack, perc(n, 0.04, 0.001)), 0.0, 0.5)
    for _ in range(26):  # falling debris
        t = rng.uniform(0.08, 1.0) ** 1.4
        d = biquad(noise(secs(0.05), rng), "bp", rng.uniform(700, 3000), 1.5)
        add_into(out, mul(d, perc(len(d), 0.012, 0.001)), t, 0.35 * (1.0 - t))
    return reverb(sat(out, 1.4), SR, 0.9, 0.22)


def sfx_stun(rng):
    n = secs(0.45)
    s = osc(n, exp_sweep(1500, 620, 0.35), ((1, 1.0), (3, 0.2)), vib=(14.0, 0.5))
    return mul(s, perc(n, 0.14, 0.003))


def sfx_player_hurt(rng):
    n = secs(0.4)
    s = osc(n, exp_sweep(330, 105, 0.28), ((1, 1.0), (2, 0.4), (3, 0.25)))
    s = sat(mul(s, perc(n, 0.12, 0.002)), 1.6)
    burst = mul(biquad(noise(n, rng), "bp", 900, 1.0), perc(n, 0.04, 0.001))
    thump = mul(osc(n, exp_sweep(160, 70, 0.1)), perc(n, 0.07))
    return [a + 0.6 * b + 0.5 * c for a, b, c in zip(s, burst, thump)]


def sfx_player_death(rng):
    n = secs(2.2)
    out = [0.0] * n
    for base in (330.0, 392.0, 494.0):
        f = lambda t, b=base: b * 2 ** (-t / 1.8) * (1 + 0.004 * math.sin(TAU * 5 * t))
        v = osc(n, f, ((1, 1.0), (2, 0.35), (3, 0.15)))
        add_into(out, mul(v, mul(attack_env(n, 0.02), exp_env(n, 0.8))), 0.0, 0.5)
    out = biquad_sweep(out, "lp", exp_sweep(3500, 300, 1.8), 0.7)
    thump = mul(osc(n, exp_sweep(150, 50, 0.4)), perc(n, 0.25))
    out = [a + 0.8 * b for a, b in zip(out, thump)]
    return reverb(out, SR, 1.6, 0.3)


def sfx_enemy_hurt(rng):
    n = secs(0.24)
    s = osc(n, exp_sweep(760, 250, 0.16), ((1, 1.0), (2, 0.3)), vib=(35.0, 1.5))
    s = mul(s, perc(n, 0.07, 0.002))
    b = mul(biquad(noise(n, rng), "bp", 1500, 1.2), perc(n, 0.03, 0.001))
    return [a + 0.4 * c for a, c in zip(s, b)]


def sfx_enemy_death(rng):
    n = secs(0.6)
    pop = mul(osc(n, exp_sweep(520, 110, 0.14)), perc(n, 0.08, 0.001))
    puff = mul(biquad_sweep(noise(n, rng), "lp", exp_sweep(3200, 300, 0.3), 0.8), perc(n, 0.15, 0.002))
    gurgle = osc(n, exp_sweep(320, 90, 0.4))
    gurgle = mul(gurgle, [0.6 + 0.4 * math.sin(TAU * 24 * i / SR) for i in range(n)])
    gurgle = mul(gurgle, perc(n, 0.2, 0.02))
    return [a + 0.7 * b + 0.4 * c for a, b, c in zip(pop, puff, gurgle)]


def sfx_spit(rng):
    n = secs(0.24)
    pfft = mul(biquad(noise(n, rng), "bp", 1900, 1.0), perc(n, 0.035, 0.002))
    blip = mul(osc(n, exp_sweep(360, 760, 0.07)), perc(n, 0.05, 0.002))
    return [a + 0.8 * b for a, b in zip(pfft, blip)]


def sfx_hollow_dash(rng):
    n = secs(0.55)
    air = biquad_sweep(noise(n, rng), "lp", lambda t: 300 + 700 * math.sin(math.pi * min(1.0, t / 0.5)), 0.9)
    air = mul(air, hump(n))
    growl = osc(n, 68.0, ((1, 1.0), (2, 0.6), (3, 0.3)))
    growl = mul(growl, [0.6 + 0.4 * math.sin(TAU * 14 * i / SR) for i in range(n)])
    growl = mul(growl, hump(n))
    return [a * 1.0 + 0.5 * b for a, b in zip(air, growl)]


def jingle(notes, spacing: float, tau: float, tail: float, rev: float, rt60: float = 1.0, vib: bool = False):
    total = spacing * len(notes) + tail
    n = secs(total)
    out = [0.0] * n
    for i, name in enumerate(notes):
        f = hz(name)
        m = n - secs(spacing * i)
        t = osc(m, f, ((1, 1.0), (2, 0.35), (3, 0.1)))
        add_into(out, mul(t, perc(m, tau, 0.004)), spacing * i, 1.0)
    return reverb(out, SR, rt60, rev)


def sfx_pickup_heart(rng):
    return jingle(["C5", "G5", "E6"], 0.085, 0.22, 0.35, 0.22)


def sfx_pickup_coin(rng):
    return jingle(["G6", "C7"], 0.06, 0.09, 0.15, 0.1, 0.5)


def sfx_pickup_key(rng):
    n = secs(0.8)
    out = [0.0] * n
    for off in (0.0, 0.07, 0.15):
        f = 1900.0 * rng.uniform(0.95, 1.07)
        for r, a, tau in ((1.0, 1.0, 0.18), (1.5, 0.5, 0.14), (2.2, 0.35, 0.1), (3.1, 0.2, 0.07)):
            m = n - secs(off)
            add_into(out, mul(osc(m, f * r), perc(m, tau, 0.001)), off, a * 0.5)
    return reverb(out, SR, 0.6, 0.15)


def sfx_pickup_pots(rng):
    n = secs(0.4)
    out = mul(osc(n, exp_sweep(210, 120, 0.07)), perc(n, 0.06))
    for off in (0.04, 0.1):
        r = mul(osc(n - secs(off), 950.0 * (1 + off), ((1, 1.0), (2.4, 0.4))), perc(n - secs(off), 0.04, 0.001))
        add_into(out, r, off, 0.4)
    return out


def sfx_pickup_core(rng):
    notes = ["C5", "E5", "G5", "C6", "E6"]
    out = jingle(notes, 0.09, 0.4, 1.0, 0.3, 1.8)
    n = len(out)
    chord = [0.0] * n
    for nm in ("C5", "G5", "C6"):
        add_into(chord, mul(osc(n, hz(nm), ((1, 1.0), (2, 0.2)), vib=(5.0, 0.1)), mul(attack_env(n, 0.3), exp_env(n, 0.6))), 0.4, 0.2)
    return [a + b for a, b in zip(out, chord)]


def sfx_pickup_item(rng):
    return jingle(["D5", "F5", "A5", "D6"], 0.1, 0.3, 0.7, 0.28, 1.4)


def sfx_gate_open(rng):
    n = secs(1.8)
    slow = biquad(noise(n, rng), "lp", 12)
    m = max(abs(v) for v in slow)
    grind_am = [0.55 + 0.45 * v / m for v in slow]
    rumble = mul(biquad(noise(n, rng), "lp", 380, 0.8), grind_am)
    grit = mul(biquad(noise(n, rng), "bp", 1300, 2.0), grind_am)
    env = [min(1.0, i / secs(0.12), (secs(1.4) - i) / secs(0.3) if i < secs(1.4) else 0.0) for i in range(n)]
    env = [max(0.0, e) for e in env]
    out = [(a + 0.35 * b) * e for a, b, e in zip(rumble, grit, env)]
    thud = mul(osc(n - secs(1.35), exp_sweep(90, 45, 0.15)), perc(n - secs(1.35), 0.12, 0.002))
    add_into(out, thud, 1.35, 1.2)
    return out


def sfx_door_unlock(rng):
    n = secs(1.1)
    out = [0.0] * n
    for off in (0.0, 0.09):
        m = n - secs(off)
        for f, a in ((2400.0, 1.0), (3300.0, 0.6)):
            add_into(out, mul(osc(m, f), perc(m, 0.012, 0.0005)), off, a * 0.5)
    clunk = mul(osc(n, exp_sweep(190, 100, 0.1)), perc(n, 0.08))
    add_into(out, clunk, 0.2, 0.8)
    creak = osc(n, exp_sweep(260, 430, 0.6), ((1, 1.0), (2, 0.5), (3, 0.4)), vib=(11.0, 0.5))
    creak = biquad(creak, "bp", 800, 0.8)
    add_into(out, mul(creak, [hump(secs(0.6))[i] if i < secs(0.6) else 0.0 for i in range(n)]), 0.3, 0.3)
    return out


def sfx_wall_break(rng):
    n = secs(1.5)
    out = [0.0] * n
    add_into(out, mul(biquad(noise(n, rng), "hp", 700), perc(n, 0.05, 0.001)), 0.0, 0.8)
    add_into(out, mul(osc(n, exp_sweep(85, 38, 0.35)), perc(n, 0.3, 0.003)), 0.0, 1.0)
    for _ in range(34):
        t = rng.uniform(0.02, 1.0) ** 1.5
        d = biquad(noise(secs(0.06), rng), "bp", rng.uniform(500, 3200), 1.6)
        add_into(out, mul(d, perc(len(d), 0.014, 0.001)), t, 0.45 * (1.1 - t))
    rumble = mul(biquad(noise(n, rng), "lp", 260), mul(attack_env(n, 0.05), exp_env(n, 0.45)))
    out = [a + 0.8 * b for a, b in zip(out, rumble)]
    return reverb(sat(out, 1.3), SR, 0.8, 0.2)


def sfx_brazier_lit(rng):
    n = secs(1.2)
    out = [0.0] * n
    whoomp = biquad_sweep(noise(n, rng), "lp", exp_sweep(220, 1900, 0.18), 0.9)
    add_into(out, mul(whoomp, mul(attack_env(n, 0.12), exp_env(n, 0.3))), 0.0, 1.0)
    add_into(out, mul(osc(n, exp_sweep(90, 150, 0.2), ((1, 1.0), (2, 0.4))), mul(attack_env(n, 0.08), exp_env(n, 0.35))), 0.0, 0.7)
    for _ in range(40):
        t = rng.uniform(0.15, 1.0)
        c = mul(biquad(noise(secs(0.012), rng), "hp", 2200), exp_env(secs(0.012), 0.003))
        add_into(out, c, t, 0.5 * (1.15 - t))
    return reverb(out, SR, 0.5, 0.12)


def sfx_room_transition(rng):
    n = secs(0.6)
    s = biquad_sweep(noise(n, rng), "bp", exp_sweep(500, 1900, 0.5), 0.8)
    s = mul(s, hump(n))
    tone = mul(osc(n, exp_sweep(260, 330, 0.5)), hump(n))
    return [a + 0.15 * b for a, b in zip(s, tone)]


def two_notes(a: str, b: str, tau: float, spacing: float, tail: float):
    n = secs(spacing + tail)
    out = [0.0] * n
    for off, nm in ((0.0, a), (spacing, b)):
        m = n - secs(off)
        t = osc(m, hz(nm), ((1, 1.0), (2, 0.25)))
        add_into(out, mul(t, perc(m, tau, 0.005)), off, 1.0)
    return biquad(out, "lp", 4000)


def sfx_pause_open(rng):
    return two_notes("G5", "D5", 0.12, 0.08, 0.3)


def sfx_pause_close(rng):
    return two_notes("D5", "G5", 0.12, 0.08, 0.3)


def sfx_menu_move(rng):
    n = secs(0.1)
    return mul(osc(n, 1250.0, ((1, 1.0), (1.5, 0.3))), perc(n, 0.016, 0.001))


def sfx_menu_select(rng):
    return two_notes("C6", "G6", 0.1, 0.06, 0.25)


SFX = {
    "swing": sfx_swing,
    "charge_start": sfx_charge_start,
    "charge_ready": sfx_charge_ready,
    "flare": sfx_flare,
    "hook_hit": sfx_hook_hit,
    "hook_clank": sfx_hook_clank,
    "bush_cut": sfx_bush_cut,
    "ward_block": sfx_ward_block,
    "moth_launch": sfx_moth_launch,
    "pot_place": sfx_pot_place,
    "pot_explode": sfx_pot_explode,
    "stun": sfx_stun,
    "player_hurt": sfx_player_hurt,
    "player_death": sfx_player_death,
    "enemy_hurt": sfx_enemy_hurt,
    "enemy_death": sfx_enemy_death,
    "spit": sfx_spit,
    "hollow_dash": sfx_hollow_dash,
    "pickup_heart": sfx_pickup_heart,
    "pickup_coin": sfx_pickup_coin,
    "pickup_key": sfx_pickup_key,
    "pickup_pots": sfx_pickup_pots,
    "pickup_core": sfx_pickup_core,
    "pickup_item": sfx_pickup_item,
    "gate_open": sfx_gate_open,
    "door_unlock": sfx_door_unlock,
    "wall_break": sfx_wall_break,
    "brazier_lit": sfx_brazier_lit,
    "room_transition": sfx_room_transition,
    "pause_open": sfx_pause_open,
    "pause_close": sfx_pause_close,
    "menu_move": sfx_menu_move,
    "menu_select": sfx_menu_select,
}


def write_wav(path: Path, x: list[float], sr: int) -> None:
    data = array.array("h", (max(-32767, min(32767, int(round(v * 32767)))) for v in x))
    if sys.byteorder == "big":
        data.byteswap()
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sr)
        w.writeframes(data.tobytes())


def build_sfx(name: str) -> str:
    rng = random.Random(seed_of(name))
    x = SFX[name](rng)
    finite(x, name)
    x = biquad(remove_dc(x), "hp", 25.0, 0.707)
    x = fade(x, 0.003, 0.03)
    x = normalise(x)
    write_wav(SFX_DIR / f"{name}.wav", x, SR)
    return name


# ---------------------------------------------------------------------------------------------
# Music
# ---------------------------------------------------------------------------------------------


def circ(fn, x: list[float]) -> list[float]:
    """Run a stateful effect over two copies of a loop and keep the second, so it is seamless."""
    y = fn(x + x)
    return y[len(x) :]


def upsample2(x: list[float]) -> list[float]:
    """x2 with a cubic (Catmull-Rom) interpolator; the loop wraps around."""
    n = len(x)
    out = [0.0] * (2 * n)
    for i in range(n):
        out[2 * i] = x[i]
        out[2 * i + 1] = (-x[i - 1] + 9.0 * x[i] + 9.0 * x[(i + 1) % n] - x[(i + 2) % n]) / 16.0
    return out


def to_ogg(x44: list[float], name: str) -> None:
    MUSIC_DIR.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        wav = Path(tmp) / f"{name}.wav"
        write_wav(wav, x44, SR)
        out = MUSIC_DIR / f"{name}.ogg"
        subprocess.run(
            ["ffmpeg", "-y", "-loglevel", "error", "-i", str(wav), "-c:a", "libvorbis", "-q:a", OGG_QUALITY,
             "-map_metadata", "-1", "-fflags", "+bitexact", "-flags:a", "+bitexact", str(out)],
            check=True,
        )


def master(mix: list[float], sr: int, rt60: float, wet: float, lp: float, drive: float) -> list[float]:
    mix = remove_dc(mix)
    mix = circ(lambda y: sat(y, drive), mix)
    mix = circ(lambda y: reverb(y, sr, rt60, wet, 0.45, 6), mix)
    mix = circ(lambda y: biquad(y, "lp", lp, 0.6, sr), mix)
    mix = circ(lambda y: biquad(y, "hp", 32.0, 0.6, sr), mix)
    return mix


# --- overworld -------------------------------------------------------------------------------

BPM_OW = 84.0
CHORDS = {
    #            bass   pad voices            arpeggio tones (rising)
    "Dm7": ("D2", ["D3", "F3", "A3", "C4"], ["D4", "F4", "A4", "C5"]),
    "G": ("G2", ["G3", "B3", "D4", "A4"], ["G4", "B4", "D5", "A4"]),
    "Cmaj7": ("C2", ["C3", "E3", "G3", "B3"], ["C4", "E4", "G4", "B4"]),
    "Am7": ("A2", ["A3", "C4", "E4", "G4"], ["A4", "C5", "E5", "G4"]),
}
PROGRESSION = ["Dm7", "G", "Cmaj7", "Am7", "Dm7", "G", "Am7", "Dm7"]

# Melody: one bar = eight eighth-note slots. A note name starts a note, "-" holds, "." is a rest.
# D dorian (D E F G A B C). Three passes: statement, higher variation, sparse low answer.
MELODY = [
    [
        "D5 - - E5 F5 - A5 -",
        "G5 - F5 - E5 - D5 -",
        "E5 - - G5 E5 - D5 C5",
        "C5 - D5 - E5 - - .",
        "F5 - - A5 G5 - F5 E5",
        "D5 - - E5 D5 - B4 -",
        "A4 - C5 - E5 - D5 C5",
        "D5 - - - - - . .",
    ],
    [
        "A5 - G5 - F5 - E5 -",
        "D5 - E5 - G5 - - .",
        "C5 - E5 - G5 - E5 -",
        "A5 - - G5 E5 - C5 -",
        "D5 - F5 - A5 - - .",
        "G5 - F5 E5 D5 - B4 -",
        "C5 - E5 - A4 - - .",
        "D5 - - - A4 - - -",
    ],
    [
        ". . A4 - D5 - - .",
        "B4 - - - D5 - - .",
        "E5 - - - G5 - - .",
        "E5 - D5 - C5 - - .",
        "F5 - - - A5 - - .",
        "G5 - - - B4 - D5 -",
        "C5 - A4 - E4 - - .",
        "D4 - - - - - - -",
    ],
]


def parse_bar(text: str):
    """-> [(slot, note name, length in slots)]"""
    notes = []
    for slot, tok in enumerate(text.split()):
        if tok == "-" and notes:
            s, nm, ln = notes[-1]
            notes[-1] = (s, nm, ln + 1)
        elif tok not in ("-", "."):
            notes.append((slot, tok, 1))
    return notes


def render_overworld() -> list[float]:
    sr = MUSIC_SR
    rng = random.Random(seed_of("overworld"))
    beat = 60.0 / BPM_OW
    bar = 4 * beat
    bars = 24
    length = secs(bars * bar, sr)
    pad = [0.0] * length
    bass = [0.0] * length
    arp = [0.0] * length
    mel = [0.0] * length
    perc_bus = [0.0] * length

    pad_cache = {}
    arp_cache = {}
    bass_cache = {}
    for b in range(bars):
        t0 = b * bar
        chord = PROGRESSION[b % 8]
        bass_n, pad_n, arp_n = CHORDS[chord]
        p = b // 8
        # pad: one soft chord per bar, overlapping its neighbours
        if chord not in pad_cache:
            pad_cache[chord] = pad_chord([hz(n) for n in pad_n], bar + 2.6, sr, 1.2, 1.6)
        add_wrap(pad, pad_cache[chord], t0 - 1.2, 0.30 if p else 0.26, sr)
        # bass: root on beat 1, softer root on beat 3
        if bass_n not in bass_cache:
            f = hz(bass_n)
            n = secs(2.2, sr)
            tone = mul(osc(n, f, ((1, 1.0), (2, 0.45), (3, 0.12)), sr), perc(n, 0.7, 0.01, sr))
            bass_cache[bass_n] = fade(tone, 0.0, 0.08, sr)
        add_wrap(bass, bass_cache[bass_n], t0, 0.55, sr)
        add_wrap(bass, bass_cache[bass_n], t0 + 2 * beat + rng.uniform(-0.01, 0.01), 0.3, sr)
        # arpeggio mallet on the off-beats, absent in the first half of the first pass
        if p > 0 or b >= 4:
            for k, slot in enumerate((1, 3, 5, 7)):
                nm = arp_n[(k + 1) % 4]
                if nm not in arp_cache:
                    arp_cache[nm] = mallet(hz(nm), 1.4, sr)
                add_wrap(arp, arp_cache[nm], t0 + slot * beat / 2 + rng.uniform(-0.008, 0.008), 0.20 * rng.uniform(0.75, 1.0), sr)
        # melody: plucked string, two slightly detuned strings
        for slot, nm, ln in parse_bar(MELODY[p][b % 8]):
            f = hz(nm)
            dur = ln * beat / 2
            t60 = 1.1 + 0.35 * ln
            ring = min(3.0, dur + 1.0)
            vel = rng.uniform(0.8, 1.0) * (0.85 if p == 2 else 1.0)
            start = t0 + slot * beat / 2 + rng.uniform(-0.012, 0.012)
            add_wrap(mel, pluck(f, ring, sr, rng, t60), start, 0.9 * vel, sr)
            add_wrap(mel, pluck(cents(f, 5.0), ring, sr, rng, t60, 0.35), start + 0.004, 0.35 * vel, sr)
        # soft folk percussion from the second pass: frame-drum thump and a brushed shaker
        if p > 0:
            n = secs(0.35, sr)
            thump = mul(osc(n, exp_sweep(118, 62, 0.15), ((1, 1.0), (2, 0.3)), sr), perc(n, 0.1, 0.003, sr))
            add_wrap(perc_bus, thump, t0, 0.32, sr)
            add_wrap(perc_bus, thump, t0 + 2.5 * beat, 0.16, sr)
            for k in range(8):
                br = mul(biquad(noise(secs(0.12, sr), rng), "hp", 4500, 0.7, sr), perc(secs(0.12, sr), 0.03, 0.006, sr))
                add_wrap(perc_bus, br, t0 + k * beat / 2, (0.1 if k % 2 else 0.06) * rng.uniform(0.7, 1.0), sr)
    # a faint breath of wind, periodic over the loop
    wind = biquad(noise(length, rng), "bp", 420.0, 1.5, sr)
    lfo_len = length / sr
    wind = [w * (0.5 + 0.5 * math.sin(TAU * 3 * (i / sr) / lfo_len)) * 0.05 for i, w in enumerate(wind)]
    mix = [a + b + c + d + e + f for a, b, c, d, e, f in zip(pad, bass, arp, mel, perc_bus, wind)]
    return master(mix, sr, 2.4, 0.30, 7000.0, 1.25)


# --- cave ------------------------------------------------------------------------------------

BPM_CAVE = 56.0
CAVE_BARS = 16
# (bar, beat, note, velocity)
CAVE_CHIMES = [
    (1, 0, "A5", 0.7), (2, 2, "F5", 0.55), (3, 1, "D5", 0.7), (4, 0, "Eb5", 0.5),
    (5, 2, "D5", 0.6), (6, 3, "A4", 0.7), (8, 1, "F5", 0.55), (9, 0, "G5", 0.6),
    (10, 2, "Eb5", 0.5), (11, 1, "D5", 0.7), (12, 3, "C5", 0.6), (13, 0, "A4", 0.7),
    (14, 2, "D5", 0.55), (15, 0, "A4", 0.5),
]  # fmt: skip
# Drone harmony as circular segments (start bar, end bar, root, fifth)
CAVE_DRONE = [(14, 24, "D2", "A2"), (8, 12, "Bb1", "F2"), (12, 14, "C2", "G2")]
CAVE_LOW = [(0, "D2"), (4, "A1"), (8, "Bb1"), (12, "C2")]


def render_cave() -> list[float]:
    sr = MUSIC_SR
    rng = random.Random(seed_of("cave"))
    beat = 60.0 / BPM_CAVE
    bar = 4 * beat
    length = secs(CAVE_BARS * bar, sr)
    ls = length / sr
    xf = 2.5 * bar / 4  # half crossfade width in seconds
    drone = [0.0] * length

    def quant(f: float, extra: int = 0) -> float:
        return (round(f * ls) + extra) / ls  # integer cycles per loop: exactly periodic

    sin = math.sin
    for b0, b1, root, fifth in CAVE_DRONE:
        s0, s1 = b0 * bar, b1 * bar
        lo, hi = s0 - xf, s1 + xf
        i0, i1 = int(lo * sr), int(hi * sr)
        voices = []
        for f, g in ((hz(root), 1.0), (hz(fifth), 0.6), (hz(root) * 2, 0.22)):
            for extra, gg in ((0, 1.0), (4, 0.8)):
                voices.append((TAU * quant(f, extra) / sr, g * gg))
        lfo = [(m, rng.uniform(0, TAU)) for m in (2, 3, 4, 5)]
        for i in range(i0, i1):
            t = i / sr
            if t < s0 + xf:
                w = sin(0.5 * math.pi * min(1.0, max(0.0, (t - lo) / (2 * xf)))) ** 2
            elif t > s1 - xf:
                w = math.cos(0.5 * math.pi * min(1.0, max(0.0, (t - (s1 - xf)) / (2 * xf)))) ** 2
            else:
                w = 1.0
            if t < s0 + xf and t > s1 - xf:  # very short segment: both fades
                w = min(w, math.cos(0.5 * math.pi * min(1.0, max(0.0, (t - (s1 - xf)) / (2 * xf)))) ** 2)
            tt = i % length
            s = 0.0
            for k, (wv, g) in enumerate(voices):
                m, ph = lfo[k % 4]
                a = 0.55 + 0.45 * sin(TAU * m * (i / sr) / ls + ph)
                s += g * a * (sin(wv * tt) + (0.3 if k >= 2 else 0.0) * sin(2 * wv * tt))
            drone[i % length] += s * w * 0.16
    sub = [0.0] * length
    wsub = TAU * quant(36.7) / sr
    for i in range(length):
        sub[i] = 0.2 * sin(wsub * i) * (0.6 + 0.4 * sin(TAU * 2 * (i / sr) / ls))

    low = [0.0] * length
    for b, nm in CAVE_LOW:
        low_note = pluck(hz(nm), 5.0, sr, rng, 3.5, 0.4, 0.3)
        add_wrap(low, low_note, b * bar + rng.uniform(0.0, 0.02), 0.5, sr)

    chimes = [0.0] * length
    for b, bt, nm, vel in CAVE_CHIMES:
        add_wrap(chimes, bell(hz(nm), 6.0, sr, 2.4), b * bar + bt * beat + rng.uniform(-0.03, 0.03), 0.22 * vel, sr)
    chimes = circ(lambda y: echo(y, 1.3 * beat, 0.5, 0.6, 3, sr)[: len(y)], chimes)

    drips = [0.0] * length
    t = rng.uniform(1.5, 3.0)
    while t < ls - 2.0:
        f0 = rng.choice([620.0, 780.0, 930.0, 1240.0])
        n = secs(0.35, sr)
        d = mul(osc(n, lambda tt, f=f0: f * (1 + 1.3 * min(1.0, tt / 0.03)), ((1, 1.0), (2, 0.15)), sr), perc(n, 0.035, 0.001, sr))
        v = rng.uniform(0.25, 0.8)
        if v < 0.45:
            d = biquad(d, "lp", 1800.0, 0.7, sr)
        add_wrap(drips, d, t, 0.18 * v, sr)
        t += rng.uniform(1.8, 5.5)
    drips = circ(lambda y: echo(y, 0.37, 0.5, 0.7, 4, sr)[: len(y)], drips)

    breath = circ(lambda y: biquad(y, "bp", 330.0, 2.0, sr), noise(length, rng))
    breath = [v * (0.5 - 0.5 * math.cos(TAU * 4 * (i / sr) / ls)) * 0.22 for i, v in enumerate(breath)]

    mix = [a + b + c + d + e + f + g for a, b, c, d, e, f, g in zip(drone, sub, low, chimes, drips, breath, [0.0] * length)]
    return master(mix, sr, 5.0, 0.45, 4800.0, 1.1)


def build_music(name: str) -> str:
    x = render_overworld() if name == "overworld" else render_cave()
    finite(x, name)
    x44 = normalise(upsample2(x))
    to_ogg(x44, name)
    return name


# ---------------------------------------------------------------------------------------------
# Check table
# ---------------------------------------------------------------------------------------------


def decode(path: Path) -> tuple[list[int], int]:
    if path.suffix == ".wav":
        with wave.open(str(path), "rb") as w:
            sr = w.getframerate()
            raw = w.readframes(w.getnframes())
    else:
        sr = SR
        raw = subprocess.run(
            ["ffmpeg", "-loglevel", "error", "-i", str(path), "-f", "s16le", "-ac", "1", "-ar", str(SR), "-"],
            check=True, capture_output=True,
        ).stdout  # fmt: skip
    a = array.array("h")
    a.frombytes(raw)
    return list(a), sr


def db(v: float) -> float:
    return 20 * math.log10(max(v, 1e-9) / 32768.0)


def check_files(files: list[Path]) -> bool:
    ok = True
    head = f"{'file':28} {'dur s':>6} {'peak dB':>8} {'rms dB':>7} {'DC':>8} {'first':>6} {'last':>6} {'first5ms':>9} {'last5ms':>8} {'seam':>8}"
    print(head)
    print("-" * len(head))
    for f in files:
        x, sr = decode(f)
        n = len(x)
        peak = max(abs(v) for v in x)
        rms = math.sqrt(sum(v * v for v in x) / n)
        dc = sum(x) / n / 32768.0
        k = int(0.005 * sr)
        first5 = max(abs(v) for v in x[:k])
        last5 = max(abs(v) for v in x[-k:])
        is_music = f.suffix == ".ogg"
        seam = ""
        if is_music:
            diffs = [abs(x[i + 1] - x[i]) for i in range(n - 1)]
            typical = sorted(diffs)[int(0.99 * len(diffs))] or 1
            jump = abs(x[0] - x[-1])
            seam = f"{jump / typical:.2f}x"
            problem = jump > 2 * typical
        else:
            problem = abs(x[0]) > 8 or abs(x[-1]) > 8 or db(last5) > -40
        problem = problem or abs(dc) > 0.005 or not (-3.6 < db(peak) < -2.4) or sr != SR
        ok = ok and not problem
        print(
            f"{f.parent.name + '/' + f.name:28} {n / sr:6.2f} {db(peak):8.2f} {db(rms):7.2f} {dc:8.5f} "
            f"{x[0]:6d} {x[-1]:6d} {db(first5):9.1f} {db(last5):8.1f} {seam:>8}{'  <-- CHECK' if problem else ''}"
        )
    print("NaN/Inf: none (render stage asserts every sample is finite). seam = |first-last| / 99th percentile of adjacent differences.")
    return ok


def all_files() -> list[Path]:
    return sorted(SFX_DIR.glob("*.wav")) + sorted(MUSIC_DIR.glob("*.ogg"))


def run_job(job: tuple[str, str]) -> str:
    kind, name = job
    return build_sfx(name) if kind == "sfx" else build_music(name)


def main(argv: list[str]) -> int:
    args = [a for a in argv if not a.startswith("--")]
    if "--check" in argv:
        return 0 if check_files(all_files()) else 1
    jobs: list[tuple[str, str]] = []
    music = ["overworld", "cave"]
    if not args:
        args = ["sfx", "music"]
    for a in args:
        if a == "sfx":
            jobs += [("sfx", n) for n in SFX]
        elif a == "music":
            jobs += [("music", n) for n in music]
        elif a in SFX:
            jobs.append(("sfx", a))
        elif a in music:
            jobs.append(("music", a))
        else:
            print(f"unknown item {a}", file=sys.stderr)
            return 2
    jobs.sort(key=lambda j: j[0] != "music")  # the slow music jobs start first
    with Pool(min(6, len(jobs))) as pool:
        for name in pool.imap_unordered(run_job, jobs):
            print("built", name, flush=True)
    return 0 if check_files(all_files()) else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
