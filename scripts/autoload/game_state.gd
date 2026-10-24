extends Node
## Run state: health, currency, keys, pitch pots, items, visited rooms and persistent flags.
## Everything that must survive a room change or a death lives here, never in a room scene.
##
## Health is in half-hearts (int). 6 = three hearts. max_health is also in half-hearts.
## Small keys are counted per scope: "ow" (the overworld) or a cave "c1" .. "c10". A key opens only
## a door of its own scope. Big keys and fragments are flags (`bigkey_cN`, `frag_cN`), one per cave.

signal health_changed(health: int, max_health: int)
signal currency_changed(value: int)
signal keys_changed(value: int)
signal pitch_pots_changed(value: int)
signal item_acquired(item_id: StringName)
signal active_item_changed(item_id: StringName)
signal room_visited(room_id: StringName)
signal flag_changed(flag: StringName, value: bool)
signal big_key_acquired(cave: StringName)
signal fragment_acquired(cave: StringName)
signal slugs_changed(value: int)

const START_HEALTH := 6
const MAX_HEALTH_CAP := 40  # 20 hearts
const PITCH_POT_MAX := 10
## Each pot bag (flags pot_bag_1 and pot_bag_2) raises the pitch pot limit by this much: 10, 14, 18.
const POT_BAG_STEP := 4
const POT_BAG_FLAGS: Array[StringName] = [&"pot_bag_1", &"pot_bag_2"]
## Wallet cap in brass. Prices are set in playtests.
const WALLET_CAP := 999
## Tallow sling ammo (decision 9): max 30; the first pickup of the sling gives 12 (ITEM_START_SLUGS).
const SLUG_MAX := 30
## Ammo granted when an item is first acquired. Plan section 4: pitch pots start at 0.
const ITEM_START_AMMO := {&"pitch_pot": 0}
const ITEM_START_SLUGS := {&"tallow_sling": 12}
## The key scopes: the overworld, then the ten caves.
const DEFAULT_SCOPE := &"ow"
const KEY_SCOPES: Array[StringName] = [
	&"ow", &"c1", &"c2", &"c3", &"c4", &"c5", &"c6", &"c7", &"c8", &"c9", &"c10"
]
const CAVE_COUNT := 10
## Caves that give a fragment. C10 (the Ninth Hollow) gives none.
const FRAGMENT_CAVES := 9

var health: int = START_HEALTH
var max_health: int = START_HEALTH
var currency: int = 0
var key_counts: Dictionary = {}  # scope (StringName) -> small keys held
## Keys of the current scope (the scope of the room the player is in). Read only: use keys_in().
var keys: int:
	get:
		return keys_in(current_scope())
var pitch_pots: int = 0
var slugs: int = 0  # tallow sling ammo, 0 to slug_max()
var items: Dictionary = {}  # item id -> true, in acquisition order
var active_item: StringName = &""
var visited_rooms: Dictionary = {}  # room id -> true
var current_room: StringName = &""
var flags: Dictionary = {}  # flag id -> true


func reset() -> void:
	health = START_HEALTH
	max_health = START_HEALTH
	currency = 0
	key_counts = {}
	pitch_pots = 0
	slugs = 0
	items = {}
	active_item = &""
	visited_rooms = {}
	current_room = &""
	flags = {}
	health_changed.emit(health, max_health)
	currency_changed.emit(currency)
	keys_changed.emit(keys)
	pitch_pots_changed.emit(pitch_pots)
	slugs_changed.emit(slugs)
	active_item_changed.emit(active_item)


## Applies damage in half-hearts. Returns true if the player is now dead.
func damage(amount: int) -> bool:
	if amount <= 0:
		return health <= 0
	health = maxi(0, health - amount)
	health_changed.emit(health, max_health)
	return health <= 0


func heal(amount: int) -> void:
	health = clampi(health + amount, 0, max_health)
	health_changed.emit(health, max_health)


func full_heal() -> void:
	health = max_health
	health_changed.emit(health, max_health)


## +1 max heart (2 half-hearts) and a full heal. Wick core.
func add_max_heart(hearts: int = 1) -> void:
	max_health = mini(MAX_HEALTH_CAP, max_health + hearts * 2)
	health = max_health
	health_changed.emit(health, max_health)


## Adds brass, capped at WALLET_CAP.
func add_currency(amount: int) -> void:
	currency = clampi(currency + amount, 0, WALLET_CAP)
	currency_changed.emit(currency)


## Spends `amount` brass. Returns false, and changes nothing, if the wallet holds less.
func spend_currency(amount: int) -> bool:
	if amount < 0 or currency < amount:
		return false
	currency -= amount
	currency_changed.emit(currency)
	return true


## The scope of the room the player is in: "ow" or "cN". "ow" when no room is known.
func current_scope() -> StringName:
	var scope := WorldData.scope_of(String(current_room))
	return StringName(scope) if scope != "" else DEFAULT_SCOPE


## Small keys held for `scope` ("ow" or "cN").
func keys_in(scope: StringName) -> int:
	return int(key_counts.get(_resolve_scope(scope), 0))


## Adds `amount` small keys of `scope`. An empty scope means the current scope.
func add_key(amount: int = 1, scope: StringName = &"") -> void:
	var s := _resolve_scope(scope)
	if not KEY_SCOPES.has(s):
		push_error("GameState.add_key: unknown key scope %s" % s)
		return
	key_counts[s] = maxi(0, keys_in(s) + amount)
	keys_changed.emit(keys)


## Spends one small key of `scope` (empty means the current scope). Returns false, and changes
## nothing, if there is none: a key never opens a door of another scope.
func use_key(scope: StringName = &"") -> bool:
	var s := _resolve_scope(scope)
	if keys_in(s) <= 0:
		return false
	key_counts[s] = keys_in(s) - 1
	keys_changed.emit(keys)
	return true


func _resolve_scope(scope: StringName) -> StringName:
	return scope if scope != &"" else current_scope()


## The pitch pot limit: PITCH_POT_MAX plus POT_BAG_STEP per pot bag held (10, 14 or 18).
func pot_max() -> int:
	var bags := 0
	for flag in POT_BAG_FLAGS:
		if has_flag(flag):
			bags += 1
	return PITCH_POT_MAX + bags * POT_BAG_STEP


## Records the next pot bag (pot_bag_1, then pot_bag_2). False when both are held.
func add_pot_bag() -> bool:
	for flag in POT_BAG_FLAGS:
		if not has_flag(flag):
			set_flag(flag)
			pitch_pots_changed.emit(pitch_pots)
			return true
	return false


func add_pitch_pots(amount: int) -> void:
	pitch_pots = clampi(pitch_pots + amount, 0, pot_max())
	pitch_pots_changed.emit(pitch_pots)


## Spends one pitch pot. Returns false (and changes nothing) if there is none.
func spend_pitch_pot() -> bool:
	if pitch_pots <= 0:
		return false
	pitch_pots -= 1
	pitch_pots_changed.emit(pitch_pots)
	return true


func slug_max() -> int:
	return SLUG_MAX


## Adds sling slugs, capped at slug_max(). Negative amounts remove slugs, never below 0.
func add_slugs(amount: int) -> void:
	slugs = clampi(slugs + amount, 0, slug_max())
	slugs_changed.emit(slugs)


## Spends one slug. Returns false (and changes nothing) if there is none.
func spend_slug() -> bool:
	if slugs <= 0:
		return false
	slugs -= 1
	slugs_changed.emit(slugs)
	return true


func has_item(item_id: StringName) -> bool:
	return items.has(item_id)


## Marks a sub-item as found. The first item found becomes the active one.
func acquire_item(item_id: StringName) -> void:
	if items.has(item_id):
		return
	items[item_id] = true
	if ITEM_START_AMMO.has(item_id):
		add_pitch_pots(int(ITEM_START_AMMO[item_id]))
	if ITEM_START_SLUGS.has(item_id):
		add_slugs(int(ITEM_START_SLUGS[item_id]))
	item_acquired.emit(item_id)
	if active_item == &"":
		set_active_item(item_id)


func set_active_item(item_id: StringName) -> void:
	if active_item == item_id:
		return
	active_item = item_id
	active_item_changed.emit(active_item)


## Acquired items in ItemRegistry order (then any unregistered ones, in acquisition order).
func acquired_item_ids() -> Array:
	var ids: Array = []
	for id in ItemRegistry.ids():
		if items.has(id):
			ids.append(id)
	for id in items.keys():
		if not ids.has(id):
			ids.append(id)
	return ids


## Switches to the next acquired item in registry order (wraps). No-op with fewer than two items.
func cycle_item() -> void:
	var ids := acquired_item_ids()
	if ids.size() < 2:
		return
	var idx: int = ids.find(active_item)
	set_active_item(ids[(idx + 1) % ids.size()])


func mark_visited(room_id: StringName) -> void:
	var scope_before := current_scope()
	current_room = room_id
	if current_scope() != scope_before:
		keys_changed.emit(keys)
	if not visited_rooms.has(room_id):
		visited_rooms[room_id] = true
		room_visited.emit(room_id)


func set_flag(flag: StringName, value: bool = true) -> void:
	if value:
		flags[flag] = true
	else:
		flags.erase(flag)
	flag_changed.emit(flag, value)


func has_flag(flag: StringName) -> bool:
	return flags.has(flag)


# ---- Big keys and fragments (one flag per cave) ------------------------------------------------


## The cave number of "cN" (1 .. CAVE_COUNT), 0 for any other scope.
func cave_number(cave: StringName) -> int:
	var text := String(cave)
	if not text.begins_with("c") or not text.substr(1).is_valid_int():
		return 0
	var number := text.substr(1).to_int()
	return number if number >= 1 and number <= CAVE_COUNT else 0


func has_big_key(cave: StringName) -> bool:
	return cave_number(cave) > 0 and has_flag(StringName("bigkey_%s" % cave))


## Records the big key of `cave` (flag bigkey_cN). False for a non-cave or a key already held.
func add_big_key(cave: StringName) -> bool:
	if cave_number(cave) == 0 or has_big_key(cave):
		return false
	set_flag(StringName("bigkey_%s" % cave))
	big_key_acquired.emit(cave)
	return true


func has_fragment(cave: StringName) -> bool:
	return _is_fragment_cave(cave) and has_flag(StringName("frag_%s" % cave))


## Records the fragment of `cave` (flag frag_cN). False for C10 (no fragment) or a repeat.
func add_fragment(cave: StringName) -> bool:
	if not _is_fragment_cave(cave) or has_fragment(cave):
		return false
	set_flag(StringName("frag_%s" % cave))
	fragment_acquired.emit(cave)
	return true


## Fragments held, 0 to FRAGMENT_CAVES. The Ninth Door needs all of them.
func fragment_count() -> int:
	var count := 0
	for number in range(1, FRAGMENT_CAVES + 1):
		if has_flag(StringName("frag_c%d" % number)):
			count += 1
	return count


func _is_fragment_cave(cave: StringName) -> bool:
	var number := cave_number(cave)
	return number >= 1 and number <= FRAGMENT_CAVES
