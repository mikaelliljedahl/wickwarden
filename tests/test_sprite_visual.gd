extends TestCase
## SpriteVisual: Placeholder fallback, facings, kinds, auto motion, variants, icons, effects.
## Uses a tiny fixture manifest (tests/fixtures/sprites_fixture), never the real art.

const FIXTURE := "res://tests/fixtures/sprites_fixture/sprites.json"


func run() -> void:
	SpriteVisual.use_manifest(FIXTURE)
	_fallback()
	_known_kind()
	_facing_and_play_anim()
	_set_kind()
	await _auto_motion()
	_variants()
	_icons_and_textures()
	await _spawn_effect()
	SpriteVisual.use_manifest(SpriteVisual.DEFAULT_MANIFEST)


func _fallback() -> void:
	var host := Node2D.new()
	add_child(host)
	check(not SpriteVisual.has_art(&"no_such_kind"), "unknown kind has no art")
	var unknown := SpriteVisual.attach(host, &"no_such_kind")
	check(unknown is Placeholder and not unknown is SpriteVisual, "unknown kind falls back to Placeholder")
	check_eq(unknown.name, &"Visual", "fallback is named Visual")
	var known_step1 := SpriteVisual.attach(host, &"spitcap", 30.0)
	check(known_step1 is Placeholder, "a step-1 kind missing from the manifest is a Placeholder")
	check_eq(host.get_child_count(), 1, "attach replaces the old Visual")
	host.queue_free()


func _known_kind() -> void:
	var host := Node2D.new()
	add_child(host)
	var visual := SpriteVisual.attach(host, &"walker")
	check(visual is SpriteVisual, "known kind gives a SpriteVisual")
	check_eq(visual.name, &"Visual", "named Visual")
	var again := SpriteVisual.attach(host, &"walker")
	check_eq(host.get_child_count(), 1, "second attach replaces the first")
	check(not is_instance_valid(visual) or visual != again, "old visual is gone")
	var sv := again as SpriteVisual
	var names := sv.sprite_frames.get_animation_names()
	for anim in ["walk_down", "walk_up", "walk_side", "swing_down"]:
		check(sv.sprite_frames.has_animation(anim), "has animation %s" % anim)
	check_eq(names.size(), 4, "exactly the manifest animations")
	check_eq(sv.sprite_frames.get_frame_count(&"walk_side"), 3, "walk_side has 3 frames")
	check_eq(sv.sprite_frames.get_frame_count(&"swing_down"), 2, "swing_down has 2 frames")
	check_near(sv.sprite_frames.get_animation_speed(&"walk_down"), 10.0, 0.01, "walk fps")
	check(not sv.sprite_frames.get_animation_loop(&"swing_down"), "swing does not loop")
	var tex := sv.sprite_frames.get_frame_texture(&"walk_side", 2) as AtlasTexture
	check(tex != null, "frames are AtlasTexture regions")
	check_eq(tex.region, Rect2(64, 0, 32, 32), "frame 2 covers x 64..96")
	check_eq(sv.texture_filter, CanvasItem.TEXTURE_FILTER_LINEAR, "linear filter")
	check_eq(sv.offset, Vector2(-16, -26), "anchor sits on the origin")
	check(sv.get_node_or_null(SpriteVisual.SHADOW_NAME) != null, "bodies get a contact shadow")
	check(not sv.is_playing(), "walk-only kind stands still on frame 0")
	check_eq(sv.animation, &"walk_down", "default is walk_down")
	# a radius override moves the anchor: soles at foot (30) land r px below the origin
	var wide := SpriteVisual.attach(host, &"walker", 10.0) as SpriteVisual
	check_eq(wide.offset, Vector2(-16, -20), "radius override moves the anchor")
	var centred := SpriteVisual.attach(host, &"blast") as SpriteVisual
	check(centred.get_node_or_null(SpriteVisual.SHADOW_NAME) == null, "centred kinds have no shadow")
	var prop := SpriteVisual.attach(host, &"torch", 0.0, Vector2(32, 32)) as SpriteVisual
	check_eq(prop.offset, Vector2(-16, -42 + 16), "prop anchor is the bottom of the size rectangle")
	check(prop.get_node_or_null(SpriteVisual.SHADOW_NAME) == null, "props have no shadow")
	host.queue_free()


func _facing_and_play_anim() -> void:
	var host := Node2D.new()
	add_child(host)
	var sv := SpriteVisual.attach(host, &"walker") as SpriteVisual
	sv.set_facing(Vector2.UP)
	check_eq(sv.animation, &"walk_up", "up picks walk_up")
	check(not sv.flip_h, "up is not flipped")
	sv.set_facing(Vector2.RIGHT)
	check_eq(sv.animation, &"walk_side", "right picks walk_side")
	check(not sv.flip_h, "right is not flipped")
	sv.set_facing(Vector2.LEFT)
	check_eq(sv.animation, &"walk_side", "left picks walk_side")
	check(sv.flip_h, "left flips side")
	sv.set_facing(Vector2(0.4, 1.0))
	check_eq(sv.animation, &"walk_down", "dominant axis wins")
	check(not sv.flip_h, "down clears the flip")
	sv.play_anim(&"walk")
	check(sv.is_playing(), "play_anim walk plays")
	sv.set_frame_and_progress(2, 0.0)
	sv.set_facing(Vector2.UP)
	check_eq(sv.frame, 2, "a facing change keeps the frame")
	sv.play_anim(&"swing")
	check_eq(sv.animation, &"walk_up", "a facing that is not drawn is a no-op")
	sv.set_facing(Vector2.DOWN)
	sv.play_anim(&"swing")
	check_eq(sv.animation, &"swing_down", "play_anim adds the facing suffix")
	sv.play_anim(&"no_such_anim")
	check_eq(sv.animation, &"swing_down", "unknown animation is a no-op")
	# kinds without facings only mirror for left
	var crawler := SpriteVisual.attach(host, &"crawler") as SpriteVisual
	crawler.set_facing(Vector2.LEFT)
	check(crawler.flip_h, "no-facing kind flips for left")
	crawler.set_facing(Vector2.DOWN)
	check(crawler.flip_h, "vertical keeps the flip")
	crawler.set_facing(Vector2.RIGHT)
	check(not crawler.flip_h, "right clears the flip")
	host.queue_free()


func _set_kind() -> void:
	var host := Node2D.new()
	add_child(host)
	var sv := SpriteVisual.attach(host, &"torch") as SpriteVisual
	check_eq(sv.animation, &"idle", "unlit torch idles")
	sv.set_kind(&"torch_lit")
	check_eq(sv.animation, &"burn", "set_kind switches to the lit frames")
	check(sv.is_playing(), "the flame plays")
	check_eq(sv.sprite_frames.get_frame_count(&"burn"), 2, "burn frames")
	host.queue_free()


func _auto_motion() -> void:
	var body := CharacterBody2D.new()
	add_child(body)
	var sv := SpriteVisual.attach(body, &"walker") as SpriteVisual
	await frames(2)
	check(not sv.is_playing(), "standing: walk frame 0, not playing")
	check_eq(sv.frame, 0, "standing shows frame 0")
	body.velocity = Vector2(120, 0)
	sv.set_facing(Vector2.RIGHT)
	await frames(2)
	check(sv.is_playing(), "moving plays walk")
	check_eq(sv.animation, &"walk_side", "moving plays the facing walk")
	body.velocity = Vector2.ZERO
	await frames(2)
	check(not sv.is_playing(), "stopped goes back to idle")
	check_eq(sv.frame, 0, "idle is frame 0")
	var bug := CharacterBody2D.new()
	add_child(bug)
	var crawler := SpriteVisual.attach(bug, &"crawler") as SpriteVisual
	await frames(2)
	check_eq(crawler.animation, &"rest", "creature rests when still")
	bug.velocity = Vector2(0, 90)
	await frames(2)
	check_eq(crawler.animation, &"fly", "creature flies when moving")
	check(crawler.is_playing(), "fly plays")
	bug.velocity = Vector2.ZERO
	await frames(2)
	check_eq(crawler.animation, &"rest", "creature rests again")
	var manual := CharacterBody2D.new()
	add_child(manual)
	var driven := SpriteVisual.attach(manual, &"walker") as SpriteVisual
	driven.auto_motion = false
	manual.velocity = Vector2(200, 0)
	await frames(2)
	check(not driven.is_playing(), "auto_motion off: the visual does not follow velocity")
	driven.play_anim(&"walk")
	check(driven.is_playing(), "auto_motion off: play_anim drives it")
	check_eq(manual.velocity, Vector2(200, 0), "the visual never writes the parent")
	await dispose(body)
	await dispose(bug)
	await dispose(manual)


func _variants() -> void:
	var host := Node2D.new()
	add_child(host)
	var seen := {}
	for i in range(12):
		var parent := Node2D.new()
		parent.position = Vector2(37.0 * i, 11.0 * i)
		host.add_child(parent)
		var sv := SpriteVisual.attach(parent, &"stone") as SpriteVisual
		var path := (sv.sprite_frames.get_frame_texture(&"idle", 0) as AtlasTexture).atlas.resource_path
		var again := SpriteVisual.attach(parent, &"stone") as SpriteVisual
		var path2 := (again.sprite_frames.get_frame_texture(&"idle", 0) as AtlasTexture).atlas.resource_path
		check_eq(path, path2, "the variant is deterministic for a position")
		seen[path] = true
	check_eq(seen.size(), 2, "both variants occur across positions")
	var forced := SpriteVisual.attach(host, &"stone") as SpriteVisual
	forced.variant_seed = 1
	forced.set_kind(&"stone")
	var forced_path := (forced.sprite_frames.get_frame_texture(&"idle", 0) as AtlasTexture).atlas.resource_path
	check(forced_path.ends_with("stone_b.png"), "variant_seed picks the variant")
	host.queue_free()


func _icons_and_textures() -> void:
	var icon := SpriteVisual.icon_of(&"walker")
	check(icon is AtlasTexture, "icon_of is an AtlasTexture")
	check_eq((icon as AtlasTexture).region, Rect2(0, 0, 32, 32), "icon is frame 0 of the default animation")
	check(SpriteVisual.icon_of(&"nope") == null, "icon_of is null without art")
	check(SpriteVisual.icon_of(&"tex_fix") == null, "terrain textures are not icons")
	var tex := SpriteVisual.texture_of(&"tex_fix")
	check(tex != null and tex.get_width() == 64, "texture_of returns the terrain texture")
	check(SpriteVisual.texture_of(&"definitely_missing") == null, "texture_of is null when missing")


func _spawn_effect() -> void:
	var host := Node2D.new()
	add_child(host)
	check(SpriteVisual.spawn_effect(host, &"nope", Vector2.ZERO) == null, "no art: null, nothing added")
	check_eq(host.get_child_count(), 0, "no art: nothing added")
	var fx := SpriteVisual.spawn_effect(host, &"blast", Vector2(50, 70))
	check(fx is SpriteVisual, "effect is a SpriteVisual")
	check(fx.top_level, "effect is top level")
	check_eq(fx.global_position, Vector2(50, 70), "effect sits at the position")
	check((fx as SpriteVisual).is_playing(), "effect plays its default animation")
	await seconds(0.5)
	check(not is_instance_valid(fx), "effect frees itself when the animation ends")
	# a looping animation is played once as an effect
	var flame := SpriteVisual.spawn_effect(host, &"torch_lit", Vector2.ZERO)
	await seconds(0.6)
	check(not is_instance_valid(flame), "a looping animation is played once and freed")
	await dispose(host)
