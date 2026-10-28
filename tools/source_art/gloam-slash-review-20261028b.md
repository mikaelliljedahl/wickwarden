# Gloam Knight slash review, 2026-10-28

Three rejected built-in ImageGen edits; model version not exposed. Design and
scale reference for each was `gloam_knight_p1_side_v1.png`, SHA-256
`0b67f91cee58a74a5616c97a96a0161be43abcf1b6d70ef2c164ccb8581e6cbc`.
Outputs remain in `~/.codex/generated_images/01a180c2-e520-79d3-af59-d07a4daa68e4/`;
none is a production source.

- `exec-11c621c4-b50e-4278-8419-45c928366a9a.png`, SHA-256
  `ac6029a8cd3e412e73070b2c353b532b1dbeeeb0af8055a374130d51a756893a`:
  requested three rows and compact slash poses. The second lance extends into
  the third pose's column; the fourth overlaps the third's horizontal extent.
- `exec-b15e9792-9fb5-4fb2-af9b-edaeb396ad4f.png`, SHA-256
  `18bd87c90eab248276ff9220c65daa710d96218db5caf74d18bf4fc51be3a580`:
  requested editing only the middle row with compact weapons. The four figures
  are separated, but the lance is dramatically shortened in poses 1 and 3.
- `exec-00b1bd5d-219c-413b-859b-e54d791e9814.png`, SHA-256
  `49ccd648ecfb622c2a9f8eef0a0d98d240fe72cd41d99ee06cdef2a5b8c20a0d`:
  requested full-length lances held near vertical. The first lance reaches into
  the row above and the second extends into the third pose's column.

All three prompts included the full shared and magenta sheet blocks from
`docs/art-brief.md`, the original image as reference, right-facing poses, and
no slash trails. All results were visually inspected. No pipeline, proof,
strip, runtime registration or import metadata was generated: none passed
the requested source acceptance gate. B07 still plays its existing visuals.
