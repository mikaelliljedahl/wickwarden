extends TestCase
## Shops: price lookup from data/shop_prices.json, walk-up purchase, denial, refills, one-time stock,
## unlocks (pot bundle after the pitch pot, slug bundle after the sling), full refusals, sold-out persistence.

const SHOP_SCENE := "res://scenes/world/shop_item.tscn"
const SHOP_SCRIPT := "res://scripts/world/shop_item.gd"
const AWAY := Vector2(-400, -400)


func run() -> void:
	_prices()
	await _ember_and_flask()
	await _denied_and_wallet_zero()
	await _walk_up_once_per_entry()
	await _pot_bundle_unlock_and_sold_out()
	await _slug_bundle_unlock_and_full_refusal()
	await _scene_and_visual()


func _prices() -> void:
	var shop_script = load(SHOP_SCRIPT)
	check_eq(shop_script.price_of(&"S1", &"ember"), 8, "S1 ember costs 8")
	check_eq(shop_script.price_of(&"S1", &"pot_bundle"), 12, "S1 pot bundle costs 12")
	check_eq(shop_script.price_of(&"S5", &"ember"), 6, "S5 ember costs 6")
	check_eq(shop_script.price_of(&"S6", &"tallow_flask"), 50, "S6 flask costs 50")
	check_eq(shop_script.price_of(&"S3", &"slug_bundle"), 10, "S3 slug bundle costs 10")
	check_eq(shop_script.price_of(&"S2", &"pot_bundle"), -1, "unsold stock has no price")
	check_eq(shop_script.price_of(&"S9", &"ember"), -1, "an unknown shop has no price")


func _ember_and_flask() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, AWAY)
	await frames(2)
	GameState.damage(4)  # health 2 of 6
	GameState.add_currency(8)
	var ember = _make_item(arena, Vector2(600, 600), &"S1", &"ember")
	await _walk_onto(player, ember)
	check_eq(GameState.health, 4, "ember heals one heart (2 half-hearts)")
	check_eq(GameState.currency, 0, "ember costs 8 brass")
	check(ember.is_offered(), "ember is refillable: still on sale")

	GameState.add_currency(8)
	await _walk_onto(player, ember)
	check_eq(GameState.health, 6, "a second ember heals to full")
	check_eq(GameState.currency, 0, "and costs 8 brass again")

	GameState.add_currency(8)
	await _walk_onto(player, ember)
	check_eq(GameState.currency, 8, "ember at full health is refused: no brass spent")
	check(ember.is_offered(), "a refused refill stays on sale")

	GameState.damage(4)
	var flask = _make_item(arena, Vector2(1000, 600), &"S2", &"tallow_flask")
	GameState.add_currency(40)
	await _walk_onto(player, flask)
	check_eq(GameState.health, 6, "the flask heals fully")
	check_eq(GameState.currency, 8, "the flask costs 40 brass")
	check(flask.is_offered(), "the flask is refillable")
	await dispose(arena)


func _denied_and_wallet_zero() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, AWAY)
	await frames(2)
	GameState.damage(2)  # health 4
	GameState.add_currency(7)
	var ember = _make_item(arena, Vector2(600, 600), &"S1", &"ember")
	await _walk_onto(player, ember)
	check_eq(GameState.health, 4, "not enough brass: nothing happens to health")
	check_eq(GameState.currency, 7, "and no brass is spent")
	check(ember.is_offered(), "the stock stays on sale")

	GameState.add_currency(1)
	await _walk_onto(player, ember)
	check_eq(GameState.health, 6, "exactly enough brass buys it")
	check_eq(GameState.currency, 0, "the wallet can reach 0")

	GameState.damage(2)
	await _walk_onto(player, ember)
	check_eq(GameState.health, 4, "with an empty wallet nothing is sold")
	check_eq(GameState.currency, 0, "and the wallet stays at 0")
	await dispose(arena)


func _walk_up_once_per_entry() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, AWAY)
	await frames(2)
	GameState.add_currency(80)
	GameState.damage(2)
	var flask = _make_item(arena, Vector2(600, 600), &"S2", &"tallow_flask")
	var sales: Array[StringName] = []
	flask.purchased.connect(func(stock: StringName) -> void: sales.append(stock))
	await _walk_onto(player, flask)
	GameState.damage(2)
	await frames(10)  # standing on the stock: no second walk-up
	check_eq(sales.size(), 1, "standing on the stock sells it once")
	await _walk_onto(player, flask)
	check_eq(sales.size(), 2, "stepping off and on again is a new walk-up")
	check_eq(GameState.currency, 0, "two flasks cost 80 brass")
	await dispose(arena)


func _pot_bundle_unlock_and_sold_out() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, AWAY)
	await frames(2)
	GameState.add_currency(999)
	var bundle = _make_item(arena, Vector2(600, 600), &"S1", &"pot_bundle", &"pot_bundle_s1")
	check(not bundle.is_offered(), "the pot bundle is not on sale before the pitch pot is found")
	check(not bundle.visible, "and it is hidden")
	await _walk_onto(player, bundle)
	check_eq(GameState.pitch_pots, 0, "walking onto it before the pot is found sells nothing")
	check_eq(GameState.currency, 999, "and spends nothing")

	GameState.acquire_item(&"pitch_pot")
	await frames(2)
	check(bundle.is_offered() and bundle.visible, "the pot bundle appears once the pot is found")
	await _walk_onto(player, bundle)
	check_eq(GameState.pitch_pots, 4, "the pot bundle gives 4 pitch pots")
	check_eq(GameState.currency, 987, "for 12 brass")
	check(GameState.has_flag(&"shop_pot_bundle_s1"), "one-time stock sets shop_<stock_id>")
	check(bundle.is_sold_out() and not bundle.visible, "and it is sold out")
	await _walk_onto(player, bundle)
	check_eq(GameState.pitch_pots, 4, "sold out: a second visit sells nothing")

	var again = _make_item(arena, Vector2(1000, 600), &"S1", &"pot_bundle", &"pot_bundle_s1")
	check(again.is_sold_out() and not again.visible, "sold-out stock stays sold on the next visit")
	await _walk_onto(player, again)
	check_eq(GameState.currency, 987, "a new node with the same id sells nothing either")

	GameState.add_pitch_pots(10)  # the limit is 10: full
	var full = _make_item(arena, Vector2(1400, 600), &"S3", &"pot_bundle", &"pot_bundle_s3")
	await _walk_onto(player, full)
	check_eq(GameState.pitch_pots, 10, "a full pot limit refuses the bundle")
	check_eq(GameState.currency, 987, "and spends nothing")
	check(full.is_offered(), "the refused bundle stays on sale")
	await dispose(arena)


func _slug_bundle_unlock_and_full_refusal() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, AWAY)
	await frames(2)
	GameState.add_currency(999)
	var slugs = _make_item(arena, Vector2(600, 600), &"S3", &"slug_bundle", &"slug_bundle_s3")
	check(not slugs.is_offered(), "the slug bundle is not on sale before the sling is found")
	await _walk_onto(player, slugs)
	check_eq(GameState.slugs, 0, "no slugs are sold before the sling")

	GameState.acquire_item(&"tallow_sling")
	await frames(2)
	check_eq(GameState.slugs, 12, "the sling starts with 12 slugs")
	await _walk_onto(player, slugs)
	check_eq(GameState.slugs, 18, "the slug bundle adds 6 slugs")
	check_eq(GameState.currency, 989, "for 10 brass")
	check(slugs.is_sold_out(), "one-time slug stock is sold out")

	GameState.add_slugs(30)  # the limit is 30: full
	var full = _make_item(arena, Vector2(1000, 600), &"S4", &"slug_bundle", &"slug_bundle_s4")
	await _walk_onto(player, full)
	check_eq(GameState.slugs, 30, "a full slug count refuses the bundle")
	check(full.is_offered(), "and the refused bundle stays on sale")
	check(not GameState.has_flag(&"shop_slug_bundle_s4"), "so no sold-out flag is set")
	await dispose(arena)


func _scene_and_visual() -> void:
	reset_state()
	var packed := load(SHOP_SCENE) as PackedScene
	check(packed != null, "scenes/world/shop_item.tscn loads")
	if packed == null:
		return
	var template := packed.instantiate()
	check(template.get_script() != null, "the scene has the shop script")
	template.free()
	var arena := make_arena()
	var item = _make_item(arena, Vector2(600, 600), &"S5", &"tallow_flask")
	await frames(2)
	check(item.get_node_or_null("Visual") != null, "a shop item has a Visual child")
	check(item.get_node_or_null("Price") != null, "and a price label")
	await dispose(arena)


## A shop item placed the way a room file places it (shop, stock, stock_id, position).
func _make_item(
	arena: Node, at: Vector2, shop_id: StringName, stock_kind: StringName, id: StringName = &""
):
	var packed := load(SHOP_SCENE) as PackedScene
	var item = packed.instantiate()
	item.shop = shop_id
	item.stock = stock_kind
	item.stock_id = id
	arena.add_child(item)
	item.global_position = at
	return item


## Walks the player away, then onto the stock: one walk-up.
func _walk_onto(player: Player, item) -> void:
	player.global_position = AWAY
	await frames(2)
	player.global_position = item.global_position
	await frames(3)
