# Wickwarden — art brief

This brief controls the image generation. The sizes, the cut rules and the file names are in
[asset-contract.md](asset-contract.md), which is normative. If this brief and the contract do not
agree, the contract is correct.

## 1. Style

- **Painterly and high detail.** Visible, confident brush strokes, soft colour transitions, rich
  material texture (brass, wax, wet moss, old wood, rough wool). It looks like a hand-painted
  storybook illustration or a modern painted indie game.
- **Never pixel art.** No pixel grid, no dithering, no hard outline around every shape, no limited
  palette, no 8-bit or 16-bit look. No look of any existing game or franchise.
- **Light is the theme.** Warm lamp light (amber, honey, brass) against a deep dusk (slate blue,
  violet grey, cold teal). Each lamp, ember and fire is the warmest and brightest thing near it.
  Everything else is muted and low in saturation.
- **View:** three-quarter top-down, as in the contract (camera about 50° above the ground). Key
  light from the upper left.
- **Original designs.** Every figure, creature and prop is designed for Wickwarden from the
  descriptions below. Do not use or imitate characters, creatures, logos or items from other games.

### Palette (indicative)

Use these values to guide the generation. Never force a finished image into them.

```
#141824 deep dusk        #252c3f dusk stone       #3b4660 cool shadow      #6a7891 lit slate
#2e3b2a dark moss        #56683f moss             #8c8f5a dry grass        #c9b98a pale straw
#f3b25c lamp amber       #ffd98a lamp core        #b0762f brass            #e7d6b0 wax
#8a3b2a rust wool        #d9a046 ochre            #5a3a28 old wood         #9b8bc4 dusk violet
```

## 2. Rules for every sheet prompt

Every prompt below starts with the **shared block**. Do not shorten it.

> Shared block: *Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted
> storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp
> light against deep dusk colours, low saturation except for light sources. NOT pixel art, no
> pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50
> degrees above the ground, key light from the upper left. No text, no letters, no numbers, no
> labels, no frame borders, no grid lines, no watermark.*

For **sprite sheets** (everything except the terrain textures) add the **sheet block**:

> Sheet block: *A sprite sheet on a perfectly flat, uniform {KEY} background that fills the whole
> image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background.
> Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses
> never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one
> shared invisible ground line and have the same scale. The figure is identical in every pose:
> same design, same colours, same proportions.*

`{KEY}` is `pure magenta #FF00FF` or `pure green #00FF00`, as each sheet says. A sheet never uses
its key colour in the subject.

For **terrain textures** add the **texture block**:

> Texture block: *A seamless tileable texture seen straight from above, filling the whole square
> image edge to edge, even lighting with no vignette and no single dominant feature, so that it
> repeats without visible seams. No objects that stand up from the surface, no perspective.*

### Generation rules

- One prompt makes one sheet. All frames of one animation come from one generation.
- Size: `1536x1024` for sprite sheets (landscape), `1024x1024` for textures, unless the sheet says
  otherwise.
- For the second and third Tamsin sheets, give the finished walk sheet as the reference image and
  write: *"Same character as in the reference image, identical design and colours."*
- Look at each result before you save it. Generate it again (at most three times) if a pose
  touches another pose, if a pose count is wrong, if the background is not flat, if there is
  text, or if the image looks like pixel art.
- Save each accepted sheet as `tools/source_art/<sheet>.png` with the exact name below.

## 3. Characters

### Tamsin Ode (the player)

A young apprentice lamplighter, about 17, slim, quick and determined. Dark brown hair in a short
thick braid, a few loose strands. A **rust-red wool coat** to mid-thigh with a wide **ochre scarf**,
dark umber trousers, worn brown leather boots, a satchel on a strap across the chest. In her right
hand she holds the **lamp hook**: a long brass pole (a little taller than she is) with a curled hook
at the top, from which a small glass-and-brass **lantern** hangs, burning with a warm amber flame.
The lantern lights her face and coat from below. Key colour: **green**.

**Sheet `tamsin_walk`** — three rows, six poses in each row, a full walk cycle with six genuinely
different poses (contact, down, passing, up, contact, passing on the other leg). Row 1: walking
towards the viewer (down). Row 2: walking away from the viewer (up), back of the coat and the
braid visible. Row 3: walking to the right in side view. The lantern swings a little with each step.

**Sheet `tamsin_swing`** — three rows (down, up, right as above), four poses in each row: wind-up
with the pole drawn back, mid-swing, full extension with the hook at the end of the arc, recovery.
The lantern flame leaves a short warm streak in poses 2 and 3. Reference image: `tamsin_walk`.

**Sheet `tamsin_states`** — three rows (down, up, right), four poses in each row: (1) charge, the
pole held back low with the lantern glowing brighter; (2) charge, the same pose with the lantern
at full bright glow; (3) ward, the lantern raised in front of her at arm's length as a shield of
light, the body braced; (4) hurt, recoiling backwards, eyes shut, arms thrown out.
Reference image: `tamsin_walk`.

## 4. The Hush (monsters)

The Hush are made of things the valley forgot: old wax, dust, lost tools, forgotten songs. They are
eerie but not gory, no blood, no skulls with gore. Each has a small cold inner glow (pale teal or
violet) that shows it is hungry for lamplight.

**Sheet `hush_spitcap`** — key **magenta**. A squat walking mushroom creature about knee high:
a broad olive and moss-green cap with pale speckles, a stubby pale stem body with two short root
legs, a dark round mouth under the cap rim that glows faint teal inside. Row 1: four walk poses
(waddling on its root legs). Row 2: two spit poses (cap tilted back, then mouth wide open and
puffing), then, to the right with a wide gap, two small poses of its **spore** projectile: a
dusty green-gold seed ball with a short wisp trail, two slightly different shapes.

**Sheet `hush_skitterwick`** — key **green**. A burnt-out candle stub that walks like a spider:
a short thick body of dark violet-grey wax with old drips, a black curled wick on top with a tiny
cold violet spark, six thin long legs made of bent iron candle-wick wire. One row of five poses:
(1–2) idle, legs shifting; (3) crouch before a jump, legs bent tight; (4–5) in the air, legs
spread, wax drips trailing.

**Sheet `hush_duskmoth`** — key **green**. A large moth made of dusk and old paper: wings of torn,
faded violet-blue paper with faint ink lines that could be old letters (not readable, no real
text), a soft grey fur body, two feathery antennae, small cold teal eyes. Row 1: two poses at rest
on the ground, wings folded in a tent shape. Row 2: four flight poses seen from above at an angle,
a full wing-beat cycle (wings up, mid, down, mid).

**Sheet `hush_tallow`** — key **magenta**. A blob of half-melted pale wax (cream, honey and dirty
white) with a few sunken old wicks sticking out and a dim violet glow deep inside. Row 1: four
poses of a slow squash-and-stretch step (flat and wide, gathering, tall, landing). Row 2: three
poses of its small **drop** offspring, a fist-sized wax drip with one tiny wick, wobbling.

**Sheet `hush_hollow`** — key **magenta**. An empty suit of old lamplighter's armour that walks
by itself: dented pewter-grey plates, a tall narrow helm with a dark empty visor and a faint cold
teal glow inside, a torn grey cloak, and a heavy iron lantern-shield on its left arm with no flame.
Row 1: four walk poses towards the viewer. Row 2: four walk poses away from the viewer. Row 3: four
walk poses to the right in side view.

## 5. Items, effects and pickups

**Sheet `items`** — key **green**. Row 1: the **tether moth**, a small tame moth of pale lavender
and cream with soft glowing amber wing edges, with a thin glowing brass thread trailing from it;
four poses of a wing-beat cycle seen from above. Row 2, with a wide gap: the **pitch pot**, a squat
round clay pot sealed with black pitch and a short twisted fuse on top; two poses, the fuse spark
small and then large.

**Sheet `fx_explosion`** — key **green**. Six frames of a pitch pot blast, seen from above at an
angle, left to right in time: a bright amber-white flash, an expanding ball of orange fire, fire
with dark pitch smoke, a ring of smoke and embers, thinning smoke with a few embers, the last faint
wisps. All six frames are the same canvas size and centred on the same point. Fire and smoke are
soft and painterly, not cartoon shapes.

**Sheet `pickups`** — key **magenta**. One row of six small objects, each a separate pickup:
(1) **ember**, a glowing coal with a small living flame; (2) **brass bit**, a small worn brass nut;
(3) **brass coin**, a thick old brass coin with a lantern stamped on it (no letters); (4) **pitch
pot bundle**, four small pitch pots tied together with twine; (5) **key**, a small iron key with a
brass bow shaped like a flame; (6) **wick core**, a heart-shaped glass bulb with a bright living
wick flame inside, the most precious object of the set.

**Sheet `braziers`** — key **magenta**. One row of five poses of the same old stone-and-iron
brazier on a short pedestal: (1) cold and unlit, grey ash in the bowl; (2–5) lit, four frames of a
looping warm fire with sparks, the flame tall above the bowl.

## 6. World

**Sheet `ow_props`** — key **magenta**. Row 1, six props with wide gaps: (1) **rock A**, a mossy
grey boulder; (2) **rock B**, a lower, flatter mossy rock pair; (3) **bush**, a round dark-green
bush with small pale blossoms; (4) **reed**, a clump of tall dusk-coloured reeds; (5) **pedestal**,
a short carved stone pedestal with a worn lantern motif; (6) **sign post**, a weathered wooden post
with a blank board (no text). Row 2, three larger props: (7) **tree A**, a gnarled dusk oak with a
dense round canopy; (8) **tree B**, a tall thin birch-like tree with pale bark; (9) **hut**, a small
round lamplighter's hut of stone and timber with a thatched roof, a warm lit window and a door
facing the viewer.

**Sheet `ow_structures`** — key **magenta**. One row of four: (1) **locked door**, a heavy wooden
door with iron bands and a big iron lock, set in a stone frame; (2) **gate**, a stone frame closed
by thick iron bars; (3) **cracked wall**, a section of ruined stone wall with a clear deep crack
from top to bottom; (4) **cave mouth**, a dark cave opening in a rocky mound, black inside, with
moss on the top.

**Sheet `cave_exit`** — key **magenta**, size `1024x1024`. One rough rock archway seen from inside
a cave, the opening filled with pale cold blue dusk light, the rock around it dark and wet.

**Textures** (texture block, no key). One image each:

| Sheet | Prompt subject |
|---|---|
| `tex_ground_grass` | short dusk meadow grass with small clover, a few pale stones and bare earth patches, muted green and straw |
| `tex_wall_hedge` | a dense, dark thorn hedge grown over mossy fieldstones, seen from above |
| `tex_wall_ruin` | the broken top of an old dry-stone wall, grey stones with moss in the joints |
| `tex_water` | dark still pond water with faint dusk reflections and a few small lily pads |
| `tex_ground_cave` | a cave floor of packed dark earth and flat slate, with small pebbles and faint damp sheen |
| `tex_wall_cave` | rough dark cave rock with cracks and a faint wet sheen |
