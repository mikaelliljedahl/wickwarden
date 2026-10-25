extends TestCase
## Real chime/hook/flare physics; cadence and attack geometry are checked independently of the kill.

const BOSS := "res://scenes/enemies/bosses/dirge_choir.tscn"
const GALLERY := "res://tests/fixtures/gallery/B06.tscn"
var arena: Node2D
var boss: Variant
var player: Player


func run() -> void:
	await _visual_adapters()
	await _intro_and_armour()
	await _real_chime_timing()
	await _songs_and_ward()
	await _fight_and_persistence()
	await _reset_and_gallery()


func _visual_adapters() -> void:
	var keys := [&"dirge_head_bass", &"dirge_head_alto", &"dirge_head_treble"]
	var image := Image.create(384, 384, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	check_eq(image.save_png("user://dirge_visual.png"), OK, "temporary art fixture saves")
	for count in [0, 1, 3]:
		var manifest := {}
		for i in range(count):
			var animations := {}
			for animation in ["idle", "telegraph", "sing"]:
				animations[animation] = {
					"file": "user://dirge_visual.png", "frames": 1, "fps": 6, "loop": true
				}
			manifest[keys[i]] = {
				"cell": [384, 384],
				"anchor": [192, 292],
				"foot": 340,
				"radius": 48,
				"animations": animations
			}
		var file := FileAccess.open("user://dirge_visual.json", FileAccess.WRITE)
		file.store_string(JSON.stringify(manifest))
		file.close()
		SpriteVisual.use_manifest("user://dirge_visual.json")
		await _setup()
		check_eq(boss.visual.visible, count < 3, "container fallback needs all three painted heads")
		for i in range(3):
			var head: Variant = boss.heads[i]
			check_eq(head.voice, i, "voice identity survives visual selection")
			check_eq(
				head.visual_kind, keys[i] if i < count else &"choir_head", "per-voice fallback"
			)
			check_eq(head.body_radius, 48.0, "paint does not change head radius")
			var body := head.get_node("BodyShape") as CollisionShape2D
			check_eq(body.shape.radius, 48.0, "paint keeps the actual body circle")
			check_eq(head.contact_hitbox.damage, 2, "paint keeps head contact damage")
			if i < count:
				check(head.visual is SpriteVisual, "available voice uses painted visual")
				check_eq(
					head.visual.offset, Vector2(-192, -292), "contract foot anchor at body centre"
				)
			else:
				check(head.visual is Placeholder, "missing voice keeps visible geometric fallback")
		if count == 3:
			await frames(95)
			boss.song_left = 100
			for head in boss.heads:
				head.cancel_song()
			var head: Variant = boss.heads[0]
			head.begin_song()
			await frames(2)
			check_eq(head.visual.animation, &"telegraph", "real song starts with warning art")
			await frames(50)
			check_eq(head.visual.animation, &"sing", "art follows real 0.8 second attack boundary")
			await _ring()
			check(head.open_left > 0, "visual adapter keeps real chime opening")
			check_eq(head.visual.animation, &"idle", "open window never shows closed stunned pose")
			check_eq(head.song_age, -1.0, "visual update does not restart cancelled song")
		await dispose(arena)
	SpriteVisual.use_manifest(SpriteVisual.DEFAULT_MANIFEST)


func _setup() -> void:
	reset_state()
	arena = make_arena()
	player = make_player(arena, Vector2(336, 480))
	var scene := load(BOSS) as PackedScene
	check(scene != null, "boss scene loads")
	if scene == null:
		return
	boss = scene.instantiate()
	arena.add_child(boss)
	await frames(3)


func _hit(head: EnemyBase, kind: StringName, damage: int = 99) -> void:
	var box := make_hitbox(arena, head.global_position, Layers.Team.PLAYER, damage, 48)
	box.kind = kind
	await frames(4)
	await dispose(box)
	await frames(20)


func _ring() -> void:
	GameState.acquire_item(&"lantern_chime")
	GameState.set_active_item(&"lantern_chime")
	Input.action_press(&"use_item")
	check(player.use_item(), "actual chime activates")
	await frames(2)
	Input.action_release(&"use_item")
	await frames(34)


func _intro_and_armour() -> void:
	await _setup()
	check_eq(boss.max_hp, 36, "total HP 36")
	check_eq(boss.heads.size(), 3, "three heads")
	for i in range(3):
		var head: Variant = boss.heads[i]
		check_eq(head.hp, 12, "each head has twelve HP")
		check_eq(head.global_position, boss.HEAD_POINTS[i], "canonical stationary head point")
		check(not head.contact_hitbox.active, "intro has no head contact")
	await _hit(boss.heads[0], &"hook")
	check_eq(boss.heads[0].hp, 12, "intro blocks damage")
	await frames(90)
	boss.song_left = 100
	for head in boss.heads:
		head.cancel_song()
		for kind in [&"hook", &"flare", &"explosion", &"sling", &"fire", &"thrown", &"stun"]:
			await _hit(head, kind)
			check_eq(head.hp, 12, "humming head blocks " + String(kind))
	check(not boss.is_arena_locked(), "boss adds no retreat lock")
	await dispose(arena)


func _real_chime_timing() -> void:
	await _setup()
	await frames(95)
	boss.song_left = 100
	var head: Variant = boss.heads[0]
	head.cancel_song()
	await _ring()
	check_eq(head.open_left, 0.0, "idle head ignores real chime")
	await frames(75)
	head.begin_song()
	await _ring()
	check(head.open_left > 3, "warning receives real expanding chime and opens for four seconds")
	check_eq(head.song_age, -1.0, "chime interrupts singing")
	for song in head.songs:
		check(not is_instance_valid(song), "chime cancels all overlapping song tails")
	await _hit(head, &"hook", 99)
	check_eq(head.hp, 10, "open head takes fixed hook two")
	await _hit(head, &"flare", 99)
	check_eq(head.hp, 6, "open head takes fixed flare four")
	await _hit(head, &"sling", 1)
	check_eq(head.hp, 5, "open mouth also accepts ordinary tool damage")
	await frames(220)
	check_eq(head.open_left, 0.0, "open window expires")
	check(head.deaf_left > 0, "three second deaf period starts after opening ends")
	head.begin_song()
	await _ring()
	check_eq(head.open_left, 0.0, "deaf singing head ignores real chime")
	await frames(190)
	head.begin_song()
	player.place_at(head.global_position + Vector2(560, 0))
	await _ring()
	check_eq(head.open_left, 0.0, "real chime beyond 480 cannot open head")
	await frames(75)
	player.place_at(head.global_position + Vector2(0, -240))
	head.begin_song()
	await frames(50)
	await _ring()
	check(head.open_left > 3, "real chime also interrupts active song")
	await dispose(arena)


func _songs_and_ward() -> void:
	await _setup()
	await frames(95)
	boss.song_left = 100
	for head in boss.heads:
		head.cancel_song()
	player.set_hurtbox_enabled(self, false)
	var bass: Variant = boss.heads[0]
	var ring: Variant = boss.make_song(bass, 0)
	await frames(45)
	check(not ring.fired and ring.box == null, "heavy Bass attack waits full 0.8 s warning")
	await frames(7)
	check_eq(ring.box.damage, 3, "Bass ring damage three")
	check(
		ring.box.blockable and not ring.box.block_destroys_carrier,
		"ward negates area without killing singer"
	)
	check(ring.progress() > 0 and ring.progress() < 0.2, "ring starts at radius zero")
	# Test the real player's ward against a Bass annulus away from its 50-degree safe wedge.
	ring.queue_free()
	await frames(3)
	player.set_hurtbox_enabled(self, true)
	player.place_at(bass.global_position + Vector2(0, -300))
	player.facing = Vector2.DOWN
	Input.action_press(&"ward")
	await frames(3)
	ring = boss.make_song(bass, 0)
	# Keep the safe wedge pointing east, rather than at our ward test position.
	await frames(50)
	ring.aim = 0
	var before := GameState.health
	await frames(35)
	check_eq(GameState.health, before, "real ward blocks Bass ring from its front")
	check(not bass.is_dead, "area ward leaves Bass alive")
	Input.action_release(&"ward")
	await frames(80)
	GameState.heal(99)
	player.place_at(bass.global_position + Vector2(300, 0))
	before = GameState.health
	ring = boss.make_song(bass, 0)
	await frames(90)
	check_eq(GameState.health, before, "aimed 50 degree wedge remains safe without ward")
	var alto: Variant = boss.heads[1]
	var cone: Variant = boss.make_song(alto, 1)
	await frames(51)
	check_eq(cone.box.damage, 2, "Alto damage two")
	var angle_before: float = cone.angle()
	await frames(15)
	check_near(
		rad_to_deg(cone.angle() - angle_before), 22.5, 2, "Alto sweeps 90 degrees per second"
	)
	var treble: Variant = boss.heads[2]
	boss.make_song(treble, 2)
	await frames(52)
	var notes: Array[Node] = []
	for node in arena.get_children():
		if node is EnemyProjectile:
			notes.append(node)
	check_eq(notes.size(), 3, "Treble emits three real homing notes")
	for note in notes:
		check_eq(note.speed, 220.0, "note speed 220")
		check_eq(note.homing_turn_deg, 120.0, "note turns 120 degrees per second")
		check_eq(note.lifetime, 3.0, "note lifetime three seconds")
	# Destroy one with a genuine hook swing, keeping it still for the isolated collision test.
	if not notes.is_empty():
		var note: Variant = notes[0]
		note.speed = 0
		player.place_at(note.global_position - Vector2(0, 70))
		player.facing = Vector2.DOWN
		Input.action_press(&"attack")
		await frames(2)
		Input.action_release(&"attack")
		await frames(15)
		check(not is_instance_valid(note), "actual hook destroys one-HP Treble note")
	await dispose(arena)


func _flare() -> void:
	Input.action_press(&"attack")
	await frames(57)
	Input.action_release(&"attack")
	await frames(23)


func _fight_and_persistence() -> void:
	await _setup()
	player.set_hurtbox_enabled(self, false)
	await frames(95)
	for index in range(3):
		boss.song_left = 100
		var head: Variant = boss.heads[index]
		player.place_at(head.global_position + Vector2(0, -110))
		player.facing = Vector2.DOWN
		head.begin_song()
		await _ring()
		check(head.open_left > 0, "real chime opens target in phase " + str(boss.phase))
		for hit in range(2):
			await _flare()
		check(
			not is_instance_valid(head) or head.is_dead,
			"two actual hook/charged-flare pairs defeat one head"
		)
		if index < 2:
			check_eq(boss.phase, index + 2, "head death advances phase")
			await frames(80)
			if index == 1:
				check_eq(boss.singers.size(), 2, "solo phase adds exactly two actual choirlings")
		else:
			check(boss.is_dying(), "last head starts death throes")
	check(GameState.has_flag(&"boss_cave_6_11_defeated"), "canonical defeat flag persists")
	check(not GameState.has_flag(&"frag_c6"), "fragment stays room-owned")
	check(not GameState.has_flag(&"picked_wick_core_c6"), "core stays room-owned")
	await frames(100)
	await dispose(arena)
	arena = make_arena()
	var scene := load(BOSS) as PackedScene
	boss = scene.instantiate()
	arena.add_child(boss)
	await frames(100)
	check(boss.is_dead and not boss.visible, "defeated boss stays retired on reload")
	check_eq(boss.parts().size(), 0, "retired boss does not recreate heads")
	await dispose(arena)


func _reset_and_gallery() -> void:
	await _setup()
	await frames(95)
	boss.heads[0].begin_song()
	boss.reset_fight()
	await frames(3)
	check_eq(boss.hp, 36, "reset restores aggregate HP")
	check_eq(boss.phase, 1, "reset restores phase one")
	check_eq(boss.parts().size(), 3, "reset rebuilds exactly three heads")
	check(boss.is_in_intro(), "reset repeats intro")
	await dispose(arena)
	reset_state()
	var scene := load(GALLERY) as PackedScene
	check(scene != null, "gallery loads")
	if scene != null:
		var fixture: Room = scene.instantiate()
		add_child(fixture)
		fixture.enter()
		await frames(100)
		check_eq(
			fixture.get_node("Enemies/DirgeChoir").parts().size(), 3, "gallery presents three heads"
		)
		var clone: Variant = fixture.get_node("Enemies/DirgeChoir")
		for i in range(3):
			var kind: StringName = clone.HEAD_ART[i]
			check_eq(clone.heads[i].voice, i, "template clone keeps voice identity")
			check_eq(
				clone.heads[i].visual_kind,
				kind if SpriteVisual.has_art(kind) else &"choir_head",
				"template clone selects the corresponding painted voice or fallback"
			)
		var live_heads := 0
		for node in fixture.get_node("Enemies").get_children():
			if node is EnemyBase and node.get("choir") != null:
				live_heads += 1
		check_eq(live_heads, 3, "room snapshot leaves no orphan heads")
		fixture.leave()
		await frames(3)
		fixture.enter()
		await frames(3)
		check(
			fixture.get_node("Enemies/DirgeChoir").is_in_intro(),
			"room leave/reentry resets encounter"
		)
		clone = fixture.get_node("Enemies/DirgeChoir")
		for i in range(3):
			check_eq(clone.heads[i].voice, i, "reentry rebuilds the same three voice identities")
		await dispose(fixture)
