# Wickwarden docs: index

Start with [state.md](state.md) for where the project stands. The rules for agents are in [../AGENTS.md](../AGENTS.md),
and the player-facing overview is in [../README.md](../README.md). Where two documents differ, a binding document wins
over a guide, and [decisions.md](decisions.md) wins over every plan.

## Binding contracts

Normative. Code and art follow these; a change goes through the owner, not through a local edit.

- [decisions.md](decisions.md): the owner's decisions of 2026-10-24; they win over the plans where they differ.
- [code-contract.md](code-contract.md): file ownership, APIs, collision layers and tests; section 16 is the world build contract.
- [asset-contract.md](asset-contract.md): the art interface: cells, foot line, strips, manifest and `SpriteVisual`.
- [monsters-bosses-tools.md](monsters-bosses-tools.md): spec of the regular monsters, minibosses, bosses and the eight tools.
- [world-graph.json](world-graph.json): the machine-readable world graph; the source of `data/world_data.json`, which is generated and never edited by hand.

## Plans

- [walkthrough.md](walkthrough.md): a player-facing guide to the start, controls, overworld route, all ten caves and endings.
- [world-plan.md](world-plan.md): the master plan for the full game (rooms, gates, caves, tools); binding.
- [world-work-packages.md](world-work-packages.md): the build plan split into work packages, owners, waves and interface contracts; binding.
- [state.md](state.md): the current status, open points and next steps; updated when a step or work package lands.
- [story.md](story.md): the story sketch; context only, not binding.
- [intro-script.md](intro-script.md): the intro text, six stills with hold times; the art inventory reads it.

## Art

- [art-brief.md](art-brief.md): the art style and the shared prompt blocks; the asset contract wins on conflict.
- [art-inventory.md](art-inventory.md): the full list of art the game needs, with sizes, frames and the 86 generation batches.
- [art-provenance.md](art-provenance.md): the origin of every source image; a new image gets its row here.
- [audio-provenance.md](audio-provenance.md): how the sounds and music are made (synthesised, no samples).
- The prompts and progress of the generation batches are in `../tools/art_prompts/` (`PROGRESS.md`).

## History

- [dev-world-plan.md](dev-world-plan.md): the step-1 plan (dev world), done; its numbers still stand where the dev rooms cite them.
- [screens/step1/](screens/step1/): screenshots of the step-1 dev world with placeholder art.
- [screens/step2/](screens/step2/): screenshots of the step-2 art pass.

`docs/.gdignore` hides this folder from the Godot importer and from exports. Nothing reads it at run time: the game
reads `data/world_data.json`.
