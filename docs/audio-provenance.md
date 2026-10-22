# Audio provenance

Every sound in the game is synthesised by [`tools/make_audio.py`](../tools/make_audio.py) from
oscillators, filtered noise, envelopes, pitch sweeps, delay and reverb. There are **no recorded
samples, no sample packs and no downloads**. The two music loops are original compositions written as
note data in the script (D dorian folk piece for the overworld, a sparse drone and chime piece for the
caves).

Output is reproducible: each item has its own fixed random seed, so the script writes the same files
every run (the .ogg bytes can differ by encoder version).

Regenerate: `make audio` (all), or `make audio ITEMS="swing cave"`. Needs Python 3 (standard library
only) and `ffmpeg` with libvorbis for the music. `python3 tools/make_audio.py --check` prints the
numeric check table (peak, RMS, DC, edges, loop seam).

Outputs: `assets/audio/sfx/*.wav` (16-bit mono 44.1 kHz) and `assets/audio/music/*.ogg` (Vorbis q4).
