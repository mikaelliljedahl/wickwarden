extends Node
## Run state: health, currency, keys, pitch pots, items, visited rooms and persistent flags.
## Everything that must survive a room change or a death lives here, never in a room scene.
##
## Health is in half-hearts (int). 6 = three hearts. max_health is also in half-hearts.

signal health_changed(health: int, max_health: int)
signal currency_changed(value: int)
signal keys_changed(value: int)
signal pitch_pots_changed(value: int)
signal item_acquired(item_id: StringName)
signal active_item_changed(item_id: StringName)
signal room_visited(room_id: StringName)
signal flag_changed(flag: StringName, value: bool)

const START_HEALTH := 6
const MAX_HEALTH_CAP := 40  # 20 hearts
const PITCH_POT_MAX := 10
## Ammo granted when an item is first acquired. Plan section 4: pitch pots start at 0.
const ITEM_START_AMMO := {&"pitch_pot": 0}

var health: int = START_HEALTH
var max_health: int = START_HEALTH
var currency: int = 0
var keys: int = 0
var pitch_pots: int = 0
var items: Dictionary = {}  # item id -> true, in acquisition order
var active_item: StringName = &""
var visited_rooms: Dictionary = {}  # room id -> true
var current_room: StringName = &""
var flags: Dictionary = {}  # flag id -> true


func reset() -> void:
	health = START_HEALTH
	max_health = START_HEALTH
	currency = 0
	keys = 0
	pitch_pots = 0
	items = {}
	active_item = &""
	visited_rooms = {}
	current_room = &""
	flags = {}
	health_changed.emit(health, max_health)
	currency_changed.emit(currency)
	keys_changed.emit(keys)
	pitch_pots_changed.emit(pitch_pots)
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


func add_currency(amount: int) -> void:
	currency = maxi(0, currency + amount)
	currency_changed.emit(currency)


func add_key(amount: int = 1) -> void:
	keys += amount
	keys_changed.emit(keys)


## Spends one key. Returns false (and changes nothing) if there is none.
func use_key() -> bool:
	if keys <= 0:
		return false
	keys -= 1
	keys_changed.emit(keys)
	return true


func add_pitch_pots(amount: int) -> void:
	pitch_pots = clampi(pitch_pots + amount, 0, PITCH_POT_MAX)
	pitch_pots_changed.emit(pitch_pots)


## Spends one pitch pot. Returns false (and changes nothing) if there is none.
func spend_pitch_pot() -> bool:
	if pitch_pots <= 0:
		return false
	pitch_pots -= 1
	pitch_pots_changed.emit(pitch_pots)
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
	item_acquired.emit(item_id)
	if active_item == &"":
		set_active_item(item_id)


func set_active_item(item_id: StringName) -> void:
	if active_item == item_id:
		return
	active_item = item_id
	active_item_changed.emit(active_item)


## Switches to the next acquired item (wraps). No-op with fewer than two items.
func cycle_item() -> void:
	var ids: Array = items.keys()
	if ids.size() < 2:
		return
	var idx: int = ids.find(active_item)
	set_active_item(ids[(idx + 1) % ids.size()])


func mark_visited(room_id: StringName) -> void:
	current_room = room_id
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
