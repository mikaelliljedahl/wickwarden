extends Area2D
## A shop pedestal: one stock item sold on a walk-up basis. Walking into the item buys it at once,
## there is no button and no text. Prices come from data/shop_prices.json (`price_of`), never from code.
##
## Stock kinds: `ember` (+1 heart, refillable), `tallow_flask` (full heal, refillable, no inventory
## slot), `pot_bundle` (+4 pitch pots, once, only after the pitch pot is found) and `slug_bundle` (+6
## sling slugs, once, only after the tallow sling is found). One-time stock sets the flag
## `shop_<stock_id>` and is gone on the next visit. A purchase needs the brass and must have an effect:
## a full heart bar, a full pot limit or a full slug count refuses it, so no one-time stock is wasted.
## A refused walk-up plays the denied sound and changes nothing.
##
## Room files place it with `shop` ("S1" .. "S6"), `stock` and `stock_id` (world-plan 6.5).

signal purchased(stock: StringName)

const PRICES_PATH := "res://data/shop_prices.json"
const STOCK_KINDS: Array[StringName] = [&"ember", &"pot_bundle", &"slug_bundle", &"tallow_flask"]
## Stock that is gone once bought (flag shop_<stock_id>). Ember and the flask can be bought again.
const ONE_TIME: Array[StringName] = [&"pot_bundle", &"slug_bundle"]
const EMBER_HEAL := 2  # half-hearts: one heart
const POT_BUNDLE_POTS := 4
const SLUG_BUNDLE_SLUGS := 6
const TRIGGER_RADIUS := 36.0
const SOLD_SFX := &"pickup_coin"
const DENIED_SFX := &"hook_clank"
## The look of each stock kind (placeholder visuals; the pickup looks are reused).
const LOOKS := {
	&"ember": &"ember",
	&"pot_bundle": &"pitch_pot_bundle",
	&"slug_bundle": &"slug_bundle",
	&"tallow_flask": &"tallow_flask",
}

static var _prices: Dictionary = {}  # shop id (String) -> {stock kind (String) -> price}
static var _prices_loaded := false

@export var shop: StringName = &""
@export var stock: StringName = &"ember"
## Id of a one-time stock item (its flag is shop_<stock_id>). Required for pot_bundle and slug_bundle.
@export var stock_id: StringName = &""

var _label: Label
var _inside := false  # the walk-up fires once per entry into the trigger


func _init() -> void:
	monitoring = true
	collision_layer = 0
	collision_mask = Layers.PICKUP_COLLECTOR


func _ready() -> void:
	add_to_group(&"shop_items")
	_register_kinds()
	if not STOCK_KINDS.has(stock):
		push_error("ShopItem: unknown stock kind %s" % stock)
	if price() < 0:
		push_error("ShopItem: no price for %s in shop %s (data/shop_prices.json)" % [stock, shop])
	if ONE_TIME.has(stock) and stock_id == &"":
		push_error("ShopItem: one-time stock %s needs a stock_id" % stock)
	var shape := CircleShape2D.new()
	shape.radius = TRIGGER_RADIUS
	var node := CollisionShape2D.new()
	node.shape = shape
	add_child(node)
	SpriteVisual.attach(self, LOOKS.get(stock, &"generic"))
	_label = Label.new()
	_label.name = "Price"
	_label.text = str(maxi(price(), 0))
	_label.position = Vector2(-18, 20)
	add_child(_label)
	GameState.item_acquired.connect(_on_item_acquired)
	GameState.flag_changed.connect(_on_flag_changed)
	_refresh()


func _exit_tree() -> void:
	if GameState.item_acquired.is_connected(_on_item_acquired):
		GameState.item_acquired.disconnect(_on_item_acquired)
	if GameState.flag_changed.is_connected(_on_flag_changed):
		GameState.flag_changed.disconnect(_on_flag_changed)


## Price in brass of `stock_kind` in `shop_id` ("S1" .. "S6"), or -1 when the file has none.
static func price_of(shop_id: StringName, stock_kind: StringName) -> int:
	_ensure_prices()
	var shop_prices: Dictionary = _prices.get(str(shop_id), {})
	return int(shop_prices.get(str(stock_kind), -1))


static func _ensure_prices() -> void:
	if _prices_loaded:
		return
	_prices_loaded = true
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(PRICES_PATH))
	if typeof(parsed) != TYPE_DICTIONARY or typeof(parsed.get("shops")) != TYPE_DICTIONARY:
		push_error('ShopItem: %s is missing or has no "shops" object' % PRICES_PATH)
		return
	_prices = parsed["shops"]


func price() -> int:
	return price_of(shop, stock)


## One-time stock that was bought stays sold: flag shop_<stock_id>.
func flag_name() -> StringName:
	return StringName("shop_%s" % stock_id)


func is_sold_out() -> bool:
	return ONE_TIME.has(stock) and GameState.has_flag(flag_name())


## True when the stock is on sale now: priced, not sold out, and unlocked by the items it needs.
func is_offered() -> bool:
	if price() < 0 or is_sold_out():
		return false
	if ONE_TIME.has(stock) and stock_id == &"":
		return false
	match stock:
		&"pot_bundle":
			return GameState.has_item(&"pitch_pot")
		&"slug_bundle":
			return GameState.has_item(&"tallow_sling")
		_:
			return true


## True when a purchase would succeed right now (on sale, enough brass, and it has an effect).
func can_buy() -> bool:
	return is_offered() and GameState.currency >= price() and _has_effect()


## Buys the stock: spends the brass, applies the effect, sets the one-time flag. False if refused.
func buy() -> bool:
	if not can_buy() or not GameState.spend_currency(price()):
		return false
	_apply_stock()
	if ONE_TIME.has(stock):
		GameState.set_flag(flag_name())
	purchased.emit(stock)
	return true


func _physics_process(_delta: float) -> void:
	var inside := _player_inside()
	if inside and not _inside:
		_walk_up()
	_inside = inside


func _player_inside() -> bool:
	for area in get_overlapping_areas():
		if area is PickupCollector and not (area as PickupCollector).carrier:
			return true
	return false


func _walk_up() -> void:
	if not is_offered():
		return
	Audio.play_sfx(SOLD_SFX if buy() else DENIED_SFX, global_position)


func _has_effect() -> bool:
	match stock:
		&"ember", &"tallow_flask":
			return GameState.health < GameState.max_health
		&"pot_bundle":
			return GameState.pitch_pots < GameState.pot_max()
		&"slug_bundle":
			return GameState.slugs < GameState.slug_max()
		_:
			return false


func _apply_stock() -> void:
	match stock:
		&"ember":
			GameState.heal(EMBER_HEAL)
		&"tallow_flask":
			GameState.full_heal()
		&"pot_bundle":
			GameState.add_pitch_pots(POT_BUNDLE_POTS)
		&"slug_bundle":
			GameState.add_slugs(SLUG_BUNDLE_SLUGS)


## Hidden while not on sale (sold out, or the item it needs is not found yet).
func _refresh() -> void:
	visible = is_offered()


func _on_item_acquired(_item_id: StringName) -> void:
	_refresh()


func _on_flag_changed(_flag: StringName, _value: bool) -> void:
	_refresh()


static func _register_kinds() -> void:
	if not Placeholder.has_kind(&"tallow_flask"):
		Placeholder.register_kind(
			&"tallow_flask", {"shape": "diamond", "color": Color(0.9, 0.6, 0.2), "radius": 14.0}
		)
	if not Placeholder.has_kind(&"slug_bundle"):
		Placeholder.register_kind(
			&"slug_bundle", {"shape": "diamond", "color": Color(0.85, 0.78, 0.55), "radius": 12.0}
		)
