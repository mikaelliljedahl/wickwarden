class_name SpriteVisual
extends AnimatedSprite2D
## Step 2 art: the painted `Visual` child (docs/asset-contract.md section 9). Replaces Placeholder
## when the manifest assets/sprites/sprites.json has the kind; Placeholder.attach is the fallback.
##
## Game logic NEVER reads from it. It only reads public state of its parent (`velocity`) to choose
## walk or idle, and never writes to the parent. `modulate` and `visible` keep their step-1 meaning.
##
## The manifest is read once (static cache). Tests call `use_manifest(path)` with a fixture manifest.

const VISUAL_NAME := "Visual"
const DEFAULT_MANIFEST := "res://assets/sprites/sprites.json"
const MOVE_THRESHOLD := 5.0
## Animations that mean "standing" and "moving", in priority order.
const IDLE_BASES: Array[StringName] = [&"idle", &"rest"]
const MOTION_BASES: Array[StringName] = [&"fly", &"move", &"walk"]
const FACINGS: Array[StringName] = [&"down", &"up", &"side"]
const SHADOW_COLOR := Color(0.04, 0.05, 0.11, 0.34)
const SHADOW_TEXTURE_SIZE := 64
const SHADOW_NAME := "ContactShadow"

static var manifest_path: String = DEFAULT_MANIFEST
static var _manifest: Dictionary = {}
static var _loaded_path: String = ""
static var _frames_cache: Dictionary = {}
static var _texture_cache: Dictionary = {}
static var _shadow_texture: Texture2D

## The state that defines the visual is exported so Node.duplicate() copies it (rooms spawn enemies
## from templates with duplicate()); _ready always rebuilds the frames from it.
## The manifest kind this node shows (may be a variant parent such as "rock").
@export var kind: StringName = &""
## Presentation only: plays the motion animation while the parent CharacterBody2D moves. The
## player wiring turns this off and drives play_anim itself.
@export var auto_motion: bool = true
## >= 0 picks the variant directly; otherwise the parent's position decides (deterministic).
@export var variant_seed: int = -1
## Overrides given to attach(): body radius (moves the anchor) and collision rectangle size (props).
@export var radius_override: float = 0.0
@export var size_override: Vector2 = Vector2.ZERO

var _once: bool = false
var _start_frame: int = 0
var _art_kind: StringName = &""
var _entry: Dictionary = {}
var _cell: Vector2 = Vector2.ZERO
var _anchor: Vector2 = Vector2.ZERO
var _has_facings: bool = false
var _mirror: bool = false
var _facing: StringName = &"down"
var _base_anim: StringName = &""
var _body: CharacterBody2D
var _moving: bool = false
var _check_variant: bool = false
var _shadow: Sprite2D
var _shadow_target: Transform2D = Transform2D.IDENTITY


## Creates (or replaces) the "Visual" child of `parent`. A SpriteVisual when the manifest has the
## kind, else a Placeholder (never a crash).
static func attach(
	parent: Node,
	entity_kind: StringName,
	radius_override_px: float = 0.0,
	size_override_px: Vector2 = Vector2.ZERO
) -> Node2D:
	if not has_art(entity_kind):
		return Placeholder.attach(parent, entity_kind, radius_override_px, size_override_px)
	var old := parent.get_node_or_null(VISUAL_NAME)
	if old != null:
		parent.remove_child(old)
		old.free()
	var visual := SpriteVisual.new()
	visual.name = VISUAL_NAME
	visual.kind = entity_kind
	visual.radius_override = radius_override_px
	visual.size_override = size_override_px
	parent.add_child(visual)
	return visual


static func has_art(entity_kind: StringName) -> bool:
	_ensure_loaded()
	var entry: Variant = _manifest.get(String(entity_kind))
	if not entry is Dictionary or entry.get("texture", false):
		return false
	return _frames_for(entity_kind) != null


## A texture by name: a terrain texture (ground_grass), or frame 0 of a kind's first animation.
static func texture_of(texture_name: StringName) -> Texture2D:
	_ensure_loaded()
	var entry: Variant = _manifest.get(String(texture_name))
	if entry is Dictionary:
		var anims: Dictionary = entry.get("animations", {})
		var rec: Variant = anims.get("idle", anims.values()[0] if not anims.is_empty() else null)
		if rec is Dictionary:
			var tex := _load_texture(String(rec["file"]))
			if tex != null and int(rec.get("frames", 1)) > 1:
				return _atlas(tex, 0, _cell_of(entry))
			return tex
	return _load_texture("res://assets/sprites/%s.png" % String(texture_name))


## Frame 0 of the kind's default animation as an AtlasTexture (HUD icons). Null without art.
static func icon_of(entity_kind: StringName) -> Texture2D:
	if not has_art(entity_kind):
		return null
	var frames := _frames_for(entity_kind)
	var anim := _default_anim(frames)
	if anim == &"" or frames.get_frame_count(anim) == 0:
		return null
	return frames.get_frame_texture(anim, 0)


## A top-level SpriteVisual at `at` that plays its default animation once and frees itself.
## `effect_scale` scales the node, `from_frame` starts the animation partway (a small puff from
## the late explosion frames), `tint` multiplies the colour. Null (nothing added) without art.
static func spawn_effect(
	parent: Node,
	entity_kind: StringName,
	at: Vector2,
	effect_scale: float = 1.0,
	from_frame: int = 0,
	tint: Color = Color.WHITE
) -> Node2D:
	if not has_art(entity_kind):
		return null
	var fx := SpriteVisual.new()
	fx.name = "Puff"  # the node name Placeholder.puff uses; tests and wiring look for it
	fx.kind = entity_kind
	fx.auto_motion = false
	fx._once = true
	fx._start_frame = from_frame
	fx.top_level = true
	fx.scale = Vector2(effect_scale, effect_scale)
	fx.modulate = tint
	parent.add_child(fx)
	fx.global_position = at
	fx.animation_finished.connect(fx.queue_free)
	return fx


## Points the class at another manifest (tests use a fixture) and forgets every cache. Use this
## instead of assigning `manifest_path` directly: Godot initialises a script's static variables
## lazily on the first static call, which would overwrite an earlier assignment.
static func use_manifest(path: String) -> void:
	reload()
	manifest_path = path


## Forgets the cached manifest, frames and textures.
static func reload() -> void:
	_manifest = {}
	_loaded_path = ""
	_frames_cache = {}
	_texture_cache = {}


static func _ensure_loaded() -> void:
	if _loaded_path == manifest_path:
		return
	_manifest = {}
	_frames_cache = {}
	_texture_cache = {}
	_loaded_path = manifest_path
	if not FileAccess.file_exists(manifest_path):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
	if parsed is Dictionary:
		_manifest = parsed


static func _cell_of(entry: Dictionary) -> Vector2:
	var cell: Array = entry.get("cell", [64, 64])
	return Vector2(float(cell[0]), float(cell[1]))


static func _atlas(tex: Texture2D, index: int, cell: Vector2) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = tex
	atlas.region = Rect2(Vector2(cell.x * index, 0.0), cell)
	return atlas


## Loads a strip with load(); before the first editor import (no .import file yet) it reads the
## PNG directly. Always null-checked, never preload.
static func _load_texture(path: String) -> Texture2D:
	if _texture_cache.has(path):
		return _texture_cache[path]
	var tex: Texture2D = null
	if ResourceLoader.exists(path):
		tex = load(path) as Texture2D
	elif FileAccess.file_exists(path):
		var image := Image.load_from_file(path)
		if image != null and not image.is_empty():
			tex = ImageTexture.create_from_image(image)
	_texture_cache[path] = tex
	return tex


static func _frames_for(entity_kind: StringName) -> SpriteFrames:
	_ensure_loaded()
	var key := String(entity_kind)
	if _frames_cache.has(key):
		return _frames_cache[key]
	var frames := _build_frames(entity_kind, false)
	_frames_cache[key] = frames
	return frames


static func _build_frames(entity_kind: StringName, once: bool) -> SpriteFrames:
	var entry: Variant = _manifest.get(String(entity_kind))
	if not entry is Dictionary:
		return null
	var kind_cell := _cell_of(entry)
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	var anims: Dictionary = entry.get("animations", {})
	for anim_name: String in anims:
		var rec: Dictionary = anims[anim_name]
		var tex := _load_texture(String(rec.get("file", "")))
		if tex == null:
			continue
		var cell := kind_cell
		if rec.has("cell"):  # a per-animation cell (wide swing frames)
			cell = Vector2(float(rec["cell"][0]), float(rec["cell"][1]))
		var count := mini(int(rec.get("frames", 1)), int(tex.get_width() / cell.x))
		if count <= 0:
			continue
		var anim := StringName(anim_name)
		frames.add_animation(anim)
		frames.set_animation_speed(anim, float(rec.get("fps", 10.0)))
		frames.set_animation_loop(anim, bool(rec.get("loop", true)) and not once)
		for i in range(count):
			frames.add_frame(anim, _atlas(tex, i, cell))
	if frames.get_animation_names().is_empty():
		return null
	return frames


## base name of an animation: "walk_side" -> "walk".
static func _strip_facing(anim: StringName) -> StringName:
	for facing in FACINGS:
		var suffix := "_" + String(facing)
		if String(anim).ends_with(suffix):
			return StringName(String(anim).trim_suffix(suffix))
	return anim


static func _find_base(frames: SpriteFrames, bases: Array[StringName]) -> StringName:
	for base in bases:
		if frames.has_animation(base) or frames.has_animation(String(base) + "_down"):
			return base
	return &""


static func _default_anim(frames: SpriteFrames) -> StringName:
	var base := _find_base(frames, IDLE_BASES + MOTION_BASES)
	if base != &"":
		return base if frames.has_animation(base) else StringName(String(base) + "_down")
	var names := frames.get_animation_names()
	return StringName(names[0]) if not names.is_empty() else &""


func _init() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	centered = false
	set_notify_local_transform(true)


func _notification(what: int) -> void:
	if what == NOTIFICATION_LOCAL_TRANSFORM_CHANGED:
		_place_shadow()


func _ready() -> void:
	_body = get_parent() as CharacterBody2D
	if not animation_finished.is_connected(_on_animation_finished):
		animation_finished.connect(_on_animation_finished)
	if not animation_changed.is_connected(_apply_offset):
		animation_changed.connect(_apply_offset)
	_shadow = get_node_or_null(SHADOW_NAME) as Sprite2D  # a duplicate() copies the child
	_build()
	if _body == null and not _check_variant:
		set_process(false)


## Switches to another kind's frames (brazier -> brazier_lit) and plays its default animation.
func set_kind(new_kind: StringName) -> void:
	kind = new_kind
	if is_inside_tree():
		_build()


## Picks _down/_up/_side by the dominant axis and mirrors `side` (or the whole figure for kinds
## without facings) for left, when the manifest says mirror_side.
func set_facing(dir: Vector2) -> void:
	if dir == Vector2.ZERO:
		return
	var new_facing := _facing
	var flip := flip_h
	if _has_facings:
		if absf(dir.x) > absf(dir.y):
			new_facing = &"side"
		elif dir.y < 0.0:
			new_facing = &"up"
		else:
			new_facing = &"down"
		flip = _mirror and new_facing == &"side" and dir.x < 0.0
	elif _mirror and absf(dir.x) > 0.001:
		flip = dir.x < 0.0
	_set_flip(flip)
	if new_facing != _facing:
		_facing = new_facing
		_refresh_facing()


## Plays `base`, or base_<facing> when the kind has facings. No-op when missing.
func play_anim(base: StringName) -> void:
	var target := _resolve(base)
	if target == &"":
		return
	var same_base := base == _base_anim
	var keep_frame := frame
	var keep_progress := frame_progress
	_base_anim = base
	if animation == target and is_playing():
		return
	var switched := animation != target
	play(target)
	if switched and same_base:
		_restore_frame(target, keep_frame, keep_progress)


func _process(_delta: float) -> void:
	if _check_variant:
		_check_variant = false
		if _pick_variant() != _art_kind:
			_build()
	if auto_motion and _body != null and sprite_frames != null:
		var moving := _body.velocity.length() > MOVE_THRESHOLD
		if moving != _moving:
			_moving = moving
			_apply_motion()


func _build() -> void:
	_ensure_loaded()
	_art_kind = _pick_variant()
	var variants: Array = _manifest.get(String(kind), {}).get("variants", [])
	_check_variant = not variants.is_empty() and variant_seed < 0
	var entry: Variant = _manifest.get(String(_art_kind))
	var frames: SpriteFrames = null
	if entry is Dictionary:
		frames = _build_frames(_art_kind, true) if _once else _frames_for(_art_kind)
	if frames == null:
		sprite_frames = null
		return
	_entry = entry
	_cell = _cell_of(_entry)
	_mirror = bool(_entry.get("mirror_side", false))
	sprite_frames = frames
	_has_facings = false
	for anim in frames.get_animation_names():
		if _strip_facing(anim) != anim:
			_has_facings = true
	_base_anim = &""
	_moving = false
	_apply_anchor()
	_update_shadow()
	_choose_default()
	_apply_offset()
	if _start_frame > 0 and sprite_frames.has_animation(animation):
		var count := sprite_frames.get_frame_count(animation)
		set_frame_and_progress(clampi(_start_frame, 0, count - 1), 0.0)


func _pick_variant() -> StringName:
	var variants: Array = _manifest.get(String(kind), {}).get("variants", [])
	if variants.is_empty():
		return kind
	var index := variant_seed
	if index < 0:
		var origin := Vector2.ZERO
		var parent := get_parent() as Node2D
		if parent != null:
			origin = parent.global_position if parent.is_inside_tree() else parent.position
		index = absi(hash(Vector2i(origin.round()))) % variants.size()
	return StringName(String(variants[index % variants.size()]))


## The manifest anchor sits on the node origin. Bodies: [W/2, foot - r]; a radius override moves
## it. Props: the anchor is the bottom centre of the collision rectangle, whose height comes from
## size_override, 2 * radius_override or the manifest's rect_h.
func _apply_anchor() -> void:
	var anchor_list: Array = _entry.get("anchor", [_cell.x * 0.5, _cell.y * 0.5])
	_anchor = Vector2(float(anchor_list[0]), float(anchor_list[1]))
	var shift := Vector2.ZERO
	if _entry.get("prop", false):
		var rect_h := float(_entry.get("rect_h", 0.0))
		if size_override.y > 0.0:
			rect_h = size_override.y
		elif radius_override > 0.0:
			rect_h = radius_override * 2.0
		shift.y = rect_h * 0.5
	elif radius_override > 0.0 and _entry.has("foot"):
		_anchor.y = float(_entry["foot"]) - radius_override
	_anchor -= shift
	_apply_offset()


## A mirrored sprite flips inside its cell, so the anchor x is measured from the right edge.
## An animation with its own cell (and anchor) uses those for its x.
func _apply_offset() -> void:
	var cell_w := _cell.x
	var anchor_x := _anchor.x
	var anims: Dictionary = _entry.get("animations", {})
	var rec: Variant = anims.get(String(animation))
	if rec is Dictionary and rec.has("cell"):
		cell_w = float(rec["cell"][0])
		anchor_x = float(rec["anchor"][0]) if rec.has("anchor") else cell_w * 0.5
	var x := cell_w - anchor_x if flip_h else anchor_x
	offset = Vector2(-x, -_anchor.y)


func _set_flip(value: bool) -> void:
	if value != flip_h:
		flip_h = value
		_apply_offset()


## Soft contact shadow under bodies. Not for centred kinds, props, or terrain (no "shadow" entry).
func _update_shadow() -> void:
	var size_list: Variant = _entry.get("shadow")
	if size_list == null:
		if _shadow != null:
			_shadow.visible = false
		return
	if _shadow == null:
		_shadow = Sprite2D.new()
		_shadow.name = SHADOW_NAME
		_shadow.show_behind_parent = true
		_shadow.texture = _shadow_gradient()
		_shadow.modulate = SHADOW_COLOR
		_shadow.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		add_child(_shadow)
	var foot_y := float(_entry.get("foot", _cell.y)) - _anchor.y
	_shadow_target = Transform2D(
		0.0,
		Vector2(float(size_list[0]) / SHADOW_TEXTURE_SIZE, float(size_list[1]) / SHADOW_TEXTURE_SIZE),
		0.0,
		Vector2(0.0, foot_y - 1.0)
	)
	_shadow.visible = true
	_place_shadow()


## The shadow stays on the ground: it cancels the Visual's own transform (a hop arc moves the
## Visual up, a squash scales it), so it sits where the entity's feet are. Presentation only.
func _place_shadow() -> void:
	if _shadow != null and is_instance_valid(_shadow):
		_shadow.transform = transform.affine_inverse() * _shadow_target


static func _shadow_gradient() -> Texture2D:
	if _shadow_texture == null:
		var gradient := Gradient.new()
		gradient.offsets = PackedFloat32Array([0.0, 0.4, 1.0])
		gradient.colors = PackedColorArray(
			[Color(1, 1, 1, 1.0), Color(1, 1, 1, 0.7), Color(1, 1, 1, 0.0)]
		)
		var texture := GradientTexture2D.new()
		texture.gradient = gradient
		texture.fill = GradientTexture2D.FILL_RADIAL
		texture.fill_from = Vector2(0.5, 0.5)
		texture.fill_to = Vector2(1.0, 0.5)
		texture.width = SHADOW_TEXTURE_SIZE
		texture.height = SHADOW_TEXTURE_SIZE
		_shadow_texture = texture
	return _shadow_texture


## "walk" -> "walk_down" (current facing) when the kind has facings and that animation exists.
func _resolve(base: StringName) -> StringName:
	if sprite_frames == null:
		return &""
	if _has_facings:
		var faced := StringName("%s_%s" % [base, _facing])
		if sprite_frames.has_animation(faced):
			return faced
	if sprite_frames.has_animation(base):
		return base
	return &""


func _restore_frame(target: StringName, wanted: int, progress: float) -> void:
	var count := sprite_frames.get_frame_count(target)
	if count > 0:
		set_frame_and_progress(clampi(wanted, 0, count - 1), progress)


## The facing changed: swap to the matching animation and keep the frame progress.
func _refresh_facing() -> void:
	var target := _resolve(_base_anim)
	if target == &"" or target == animation:
		return
	var keep_frame := frame
	var keep_progress := frame_progress
	var was_playing := is_playing()
	if was_playing:
		play(target)
	else:
		animation = target
		stop()
	_restore_frame(target, keep_frame, keep_progress)


func _hold_first_frame(base: StringName) -> void:
	var target := _resolve(base)
	if target == &"":
		return
	_base_anim = base
	animation = target
	stop()
	set_frame_and_progress(0, 0.0)


func _idle_base() -> StringName:
	return _find_base(sprite_frames, IDLE_BASES)


func _motion_base() -> StringName:
	return _find_base(sprite_frames, MOTION_BASES)


## Standing: the idle/rest animation, else frame 0 of the motion animation.
func _show_idle() -> void:
	var idle := _idle_base()
	if idle != &"":
		play_anim(idle)
	else:
		_hold_first_frame(_motion_base())


func _apply_motion() -> void:
	if _moving and _motion_base() != &"":
		play_anim(_motion_base())
	else:
		_show_idle()


func _choose_default() -> void:
	if auto_motion and _body != null:
		_show_idle()
		return
	var idle := _idle_base()
	var motion := _motion_base()
	if idle != &"":
		play_anim(idle)
	elif motion != &"" and motion != &"walk":
		play_anim(motion)
	elif motion != &"":
		_hold_first_frame(motion)
	else:
		var names := sprite_frames.get_animation_names()
		_base_anim = _strip_facing(StringName(names[0]))
		play(StringName(names[0]))


## A non-looping animation (spit, hurt) ended: fall back to what the parent is doing.
func _on_animation_finished() -> void:
	if auto_motion and _body != null and not _once:
		_apply_motion()
