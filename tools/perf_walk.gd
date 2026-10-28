extends RefCounted
## The instant-warp benchmark measures synchronous switch work including neighbour
## instantiation. The separate slide probe moves by input after placing the player
## near each exit. The separate broad survey visits all scene-backed targets;
## none of these probes is a continuous full-world walk.

const ROUTE: Array[StringName] = [&"ow_1_0", &"ow_1_1", &"ow_0_1", &"ow_0_0"]
const CHANGES := 300
const WARMUP := 100
const BUDGET_MS := 50.0


func sample() -> Dictionary:
	return {
		"nodes": int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)),
		"memory": int(Performance.get_monitor(Performance.MEMORY_STATIC)),
		"orphans": int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)),
	}


## Three passes over all scene-backed graph targets. Instant warps exercise loading,
## not navigation or input. Repeating the same order makes per-target comparisons
## meaningful even when rooms have very different node counts.
func survey(world: World) -> Dictionary:
	var targets: Array[String] = WorldData.room_ids()
	targets.append_array(WorldData.all_pockets())
	targets = targets.filter(func(id: String) -> bool: return not WorldData.scene_path(id).is_empty())
	targets.sort()
	var passes: Array = []
	var max_usec := 0
	var slowest := ""
	var slowest_pass := 0
	var total_usec := 0
	var valid := true
	world.start_at(&"ow_0_0")
	world.player.set_hurtbox_enabled(world, false)
	# Keep the controlled placement from triggering an unrelated transition.
	world.set_physics_process(false)
	for lap in range(3):
		var samples: Array = []
		for id: String in targets:
			var before := Time.get_ticks_usec()
			world.warp_to(StringName(id), &"Default", false)
			var elapsed := Time.get_ticks_usec() - before
			if elapsed > max_usec:
				max_usec = elapsed
				slowest = id
				slowest_pass = lap + 1
			total_usec += elapsed
			valid = valid and world.get_current_room_id() == StringName(id)
			await world.get_tree().process_frame
			samples.append(sample())
		passes.append(samples)
	world.set_physics_process(true)
	world.player.set_hurtbox_enabled(world, true)
	return {
		"targets": targets, "passes": passes, "valid": valid,
		"max_ms": max_usec / 1000.0,
		"slowest": slowest, "slowest_pass": slowest_pass,
		"mean_ms": total_usec / 1000.0 / (targets.size() * 3),
	}


func run(world: World) -> Dictionary:
	var samples: Array[Dictionary] = []
	var max_usec := 0
	var total_usec := 0
	var changes := 0
	var valid := true
	var adjacent := true
	var streaming := true
	world.start_at(&"ow_0_0")
	for i in range(CHANGES):
		var id := ROUTE[i % ROUTE.size()]
		var old := world.current_room
		var delta := WorldData.grid(String(id)) - old.grid
		var side := {Vector2i.UP: &"n", Vector2i.DOWN: &"s", Vector2i.LEFT: &"w", Vector2i.RIGHT: &"e"}
		adjacent = adjacent and side.has(delta) and old.has_exit(side.get(delta, &""))
		var before := Time.get_ticks_usec()
		world.warp_to(id, &"Default", false)
		var elapsed := Time.get_ticks_usec() - before
		max_usec = maxi(max_usec, elapsed)
		total_usec += elapsed
		valid = valid and world.get_current_room_id() == id
		changes += 1
		# Unloaded rooms use queue_free; sample only after the deletion queue drains.
		await world.get_tree().process_frame
		var allowed: Array[Vector2i] = [world.current_room.grid]
		for exit_side in world.current_room.exits:
			var vectors := {&"n": Vector2i.UP, &"s": Vector2i.DOWN, &"w": Vector2i.LEFT, &"e": Vector2i.RIGHT}
			allowed.append(world.current_room.grid + vectors[exit_side])
		for loaded: Room in world.rooms.values():
			streaming = streaming and allowed.has(loaded.grid)
		if changes >= WARMUP and changes % ROUTE.size() == 0:
			samples.append(sample())
	var budget := BUDGET_MS
	var override := OS.get_environment("WICKWARDEN_ROOM_BUDGET_MS")
	if override.is_valid_float() and float(override) > 0.0:
		budget = float(override)
	return {
		"valid": valid, "adjacent": adjacent, "streaming": streaming,
		"changes": changes, "samples": samples,
		"max_ms": max_usec / 1000.0, "mean_ms": total_usec / 1000.0 / changes,
		"budget_ms": budget,
	}


func walk_slides(world: World) -> Dictionary:
	var samples: Array[Dictionary] = []
	var completed := 0
	var error := ""
	world.start_at(&"ow_0_0")
	world.player.set_hurtbox_enabled(world, false)
	for i in range(CHANGES):
		var id := ROUTE[i % ROUTE.size()]
		var dir := WorldData.grid(String(id)) - world.current_room.grid
		var action: StringName = {
			Vector2i.RIGHT: &"move_right", Vector2i.DOWN: &"move_down",
			Vector2i.LEFT: &"move_left", Vector2i.UP: &"move_up"
		}.get(dir, &"")
		if action == &"":
			error = "non-adjacent route step %d" % i
			break
		var rect := world.current_room.get_rect()
		var center := rect.get_center()
		var near := center + Vector2(dir) * (rect.size * 0.5 - Vector2(35, 35))
		world.player.place_at(near)
		await world.get_tree().physics_frame
		Input.action_press(action)
		var guard := 0
		while not world.is_transitioning() and guard < 90:
			await world.get_tree().physics_frame
			guard += 1
		Input.action_release(action)
		if not world.is_transitioning():
			error = "no slide from %s toward %s at step %d" % [world.get_current_room_id(), id, i]
			break
		guard = 0
		while world.is_transitioning() and guard < 90:
			await world.get_tree().physics_frame
			guard += 1
		if world.is_transitioning() or world.get_current_room_id() != id:
			error = "slide did not reach %s at step %d" % [id, i]
			break
		completed += 1
		await world.get_tree().process_frame
		if completed >= WARMUP and completed % ROUTE.size() == 0:
			samples.append(sample())
	world.player.set_hurtbox_enabled(world, true)
	return {"completed": completed, "samples": samples, "error": error}
