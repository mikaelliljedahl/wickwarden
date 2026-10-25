extends CanvasLayer
## Item subscreen (decision 6, decision 20). A pause-style grid of every sub-item in registry order.
## `item_menu` (Tab, gamepad Select) opens it and pauses the tree like the pause menu. Move keys
## select, `confirm` equips a found item and closes, `item_menu` or `pause` closes without change.
## Found items use accepted object art, with coloured shapes when art is absent.
## Unfound items keep dark silhouettes.
## No help text here: button help lives only in the pause menu.

const TITLE := "ITEMS"
const TITLE_Y := 210.0
const FONT_TITLE := 72
const FONT_NAME := 56
const FONT_LABEL := 26
const FONT_VALUE := 48
const COLUMNS := 5
const CELL := Vector2(240, 200)
const GAP := 24.0
const GRID_TOP := 290.0
const NAME_Y := 800.0
const STRIP_TOP := 860.0
const STRIP_HEIGHT := 160.0
const SOCKETS := 9
const SOCKET_RADIUS := 18.0
const SOCKET_STEP := 44.0
const ICON_RADIUS := 56.0
## Group of the open menu. The pause menu reads it so the pause key closes this menu, not opens its own.
const OPEN_GROUP := &"item_menu_open"
const BACKDROP := Color(0, 0, 0, 0.85)
const CELL_FILL := Color(0.13, 0.13, 0.17)
const FRAME_COLOR := Color(0.35, 0.33, 0.28)
const SELECT_COLOR := Color(1.0, 0.85, 0.4)
const SILHOUETTE := Color(0.04, 0.04, 0.06)
const TEXT_COLOR := Color(0.92, 0.88, 0.78)
const MUTED_COLOR := Color(0.5, 0.5, 0.55)
const ACCENT := Color(0.95, 0.75, 0.35)
const STRIP_FILL := Color(0.1, 0.1, 0.13)
const SOCKET_EMPTY := Color(0.2, 0.2, 0.25)
## Placeholder look per sub-item: a shape and a colour. An unknown id gets a grey square.
const LOOK := {
	&"tether_moth": {"shape": &"circle", "color": Color(0.8, 0.72, 0.52)},
	&"pitch_pot": {"shape": &"circle", "color": Color(0.85, 0.45, 0.2)},
	&"cinder_wick": {"shape": &"diamond", "color": Color(0.95, 0.55, 0.2)},
	&"tallow_sling": {"shape": &"triangle", "color": Color(0.85, 0.8, 0.6)},
	&"reed_raft": {"shape": &"square", "color": Color(0.55, 0.7, 0.45)},
	&"heft_mitts": {"shape": &"bar", "color": Color(0.6, 0.5, 0.4)},
	&"glow_jar": {"shape": &"circle", "color": Color(0.7, 0.95, 0.7)},
	&"lantern_chime": {"shape": &"triangle", "color": Color(0.95, 0.85, 0.4)},
	&"skitter_boots": {"shape": &"diamond", "color": Color(0.6, 0.8, 0.95)},
	&"reel_line": {"shape": &"bar", "color": Color(0.75, 0.75, 0.8)},
}
const DEFAULT_LOOK := {"shape": &"square", "color": Color(0.6, 0.6, 0.6)}

var is_open: bool = false
var selected: int = 0  # index into item_ids()
var _canvas: Control


func _ready() -> void:
	layer = 30
	process_mode = Node.PROCESS_MODE_ALWAYS
	_canvas = Control.new()
	_canvas.name = "Canvas"
	_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_canvas.visible = false
	_canvas.draw.connect(_draw_menu)
	add_child(_canvas)


func _unhandled_input(event: InputEvent) -> void:
	if is_open:
		_handle_open_input(event)
	elif event.is_action_pressed(&"item_menu") and _can_open():
		set_open(true)
		get_viewport().set_input_as_handled()


## Every sub-item id, in registry order (the grid order).
func item_ids() -> Array:
	return ItemRegistry.ids()


func selected_id() -> StringName:
	var ids := item_ids()
	if selected < 0 or selected >= ids.size():
		return &""
	return ids[selected]


## True if the item has been found (eligible for art, rather than a silhouette).
func is_found(id: StringName) -> bool:
	return GameState.has_item(id)


func set_open(value: bool) -> void:
	is_open = value
	_canvas.visible = value
	if value:
		selected = maxi(0, item_ids().find(GameState.active_item))
		add_to_group(OPEN_GROUP)
	else:
		remove_from_group(OPEN_GROUP)
	get_tree().paused = value
	_canvas.queue_redraw()


func _handle_open_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"item_menu") or event.is_action_pressed(&"pause"):
		set_open(false)
	elif event.is_action_pressed(&"confirm"):
		_equip_selected()
	elif event.is_action_pressed(&"move_left", true):
		_move(-1, 0)
	elif event.is_action_pressed(&"move_right", true):
		_move(1, 0)
	elif event.is_action_pressed(&"move_up", true):
		_move(0, -1)
	elif event.is_action_pressed(&"move_down", true):
		_move(0, 1)
	else:
		return
	get_viewport().set_input_as_handled()


## Opens only when the game is running: not while the tree is paused (pause menu) and not during
## a room slide, fade or death wait (World.phase).
func _can_open() -> bool:
	if get_tree().paused:
		return false
	var world := get_tree().get_first_node_in_group(&"world") as World
	return world == null or world.phase == World.Phase.NONE


## An unfound item cannot be equipped: the menu stays open and nothing changes.
func _equip_selected() -> void:
	var id := selected_id()
	if id == &"" or not is_found(id):
		return
	GameState.set_active_item(id)
	set_open(false)


## Moves the selection, clamped to the grid (no wrap). The last row may be short.
@warning_ignore("integer_division")
func _move(dx: int, dy: int) -> void:
	var count := item_ids().size()
	if count == 0:
		return
	var col := clampi(selected % COLUMNS + dx, 0, COLUMNS - 1)
	var row := clampi(selected / COLUMNS + dy, 0, (count - 1) / COLUMNS)
	selected = mini(row * COLUMNS + col, count - 1)
	_canvas.queue_redraw()


# ---- Drawing -------------------------------------------------------------------------------------


func _draw_menu() -> void:
	var area := _canvas.size
	var font := ThemeDB.fallback_font
	_canvas.draw_rect(Rect2(Vector2.ZERO, area), BACKDROP)
	_canvas.draw_string(
		font,
		Vector2(0, TITLE_Y),
		TITLE,
		HORIZONTAL_ALIGNMENT_CENTER,
		area.x,
		FONT_TITLE,
		TEXT_COLOR
	)
	var left := _grid_left(area.x)
	var ids := item_ids()
	for index in ids.size():
		_draw_cell(font, Vector2(left, GRID_TOP), index, ids[index])
	_draw_name(font, area.x, selected_id())
	_draw_status(font, left)


func _grid_left(width: float) -> float:
	var grid_width := COLUMNS * CELL.x + (COLUMNS - 1) * GAP
	return (width - grid_width) / 2.0


@warning_ignore("integer_division")
func _draw_cell(font: Font, origin: Vector2, index: int, id: StringName) -> void:
	var offset := Vector2(index % COLUMNS, index / COLUMNS) * (CELL + Vector2(GAP, GAP))
	var rect := Rect2(origin + offset, CELL)
	var look := _look(id)
	_canvas.draw_rect(rect, CELL_FILL)
	if index == selected:
		_canvas.draw_rect(rect, SELECT_COLOR, false, 6.0)
	else:
		_canvas.draw_rect(rect, FRAME_COLOR, false, 2.0)
	var centre := rect.position + Vector2(CELL.x / 2.0, 96.0)
	if is_found(id):
		var icon := _icon_for(id)
		if icon != null:
			var extent := icon.get_size()
			extent *= ICON_RADIUS * 2.0 / maxf(extent.x, extent.y)
			_canvas.draw_texture_rect(icon, Rect2(centre - extent * 0.5, extent), false)
		else:
			_draw_shape(look["shape"], centre, ICON_RADIUS, look["color"])
	else:
		_draw_shape(look["shape"], centre, ICON_RADIUS, SILHOUETTE)
		_canvas.draw_string(
			font,
			centre + Vector2(-CELL.x / 2.0, 22.0),
			"?",
			HORIZONTAL_ALIGNMENT_CENTER,
			CELL.x,
			64,
			MUTED_COLOR
		)
	if GameState.active_item == id:
		_canvas.draw_string(
			font,
			rect.position + Vector2(0, CELL.y - 20.0),
			"EQUIPPED",
			HORIZONTAL_ALIGNMENT_CENTER,
			CELL.x,
			FONT_LABEL,
			ACCENT
		)


func _draw_name(font: Font, width: float, id: StringName) -> void:
	if id == &"":
		return
	var text := ItemRegistry.display_name(id) if is_found(id) else "Not found yet"
	var colour := TEXT_COLOR if is_found(id) else MUTED_COLOR
	_canvas.draw_string(
		font, Vector2(0, NAME_Y), text, HORIZONTAL_ALIGNMENT_CENTER, width, FONT_NAME, colour
	)


## Status strip: the nine fragment sockets, the big key of the current cave and the hearts.
func _draw_status(font: Font, left: float) -> void:
	var grid_width := COLUMNS * CELL.x + (COLUMNS - 1) * GAP
	var strip := Rect2(Vector2(left, STRIP_TOP), Vector2(grid_width, STRIP_HEIGHT))
	_canvas.draw_rect(strip, STRIP_FILL)
	var top := strip.position
	_canvas.draw_string(
		font,
		top + Vector2(40, 52),
		"FRAGMENTS",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		FONT_LABEL,
		TEXT_COLOR
	)
	for number in range(1, SOCKETS + 1):
		var centre := top + Vector2(40 + SOCKET_RADIUS + (number - 1) * SOCKET_STEP, 100)
		var lit := GameState.has_fragment(StringName("c%d" % number))
		_draw_socket(centre, ACCENT if lit else SOCKET_EMPTY)
	var big_x := top.x + 470.0
	_canvas.draw_string(
		font,
		Vector2(big_x, top.y + 52),
		"BIG KEY",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		FONT_LABEL,
		TEXT_COLOR
	)
	var cave := GameState.current_scope()
	if GameState.cave_number(cave) > 0:
		var held := GameState.has_big_key(cave)
		_draw_socket(Vector2(big_x + 24.0, top.y + 110.0), ACCENT if held else SOCKET_EMPTY)
		_canvas.draw_string(
			font,
			Vector2(big_x + 60.0, top.y + 124.0),
			String(cave).to_upper(),
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			FONT_VALUE,
			TEXT_COLOR
		)
	else:
		_canvas.draw_string(
			font,
			Vector2(big_x, top.y + 124.0),
			"none here",
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			FONT_VALUE,
			MUTED_COLOR
		)
	var hearts_x := top.x + 900.0
	_canvas.draw_string(
		font,
		Vector2(hearts_x, top.y + 52),
		"HEARTS",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		FONT_LABEL,
		TEXT_COLOR
	)
	var value := "%s / %s" % [_hearts(GameState.health), _hearts(GameState.max_health)]
	_canvas.draw_string(
		font,
		Vector2(hearts_x, top.y + 124.0),
		value,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		FONT_VALUE,
		TEXT_COLOR
	)


## Half-hearts as hearts: 6 is "3", 5 is "2.5".
@warning_ignore("integer_division")
func _hearts(half_hearts: int) -> String:
	if half_hearts % 2 == 0:
		return "%d" % (half_hearts / 2)
	return "%d.5" % (half_hearts / 2)


func _draw_socket(centre: Vector2, colour: Color) -> void:
	_canvas.draw_circle(centre, SOCKET_RADIUS, colour)
	_canvas.draw_arc(centre, SOCKET_RADIUS, 0.0, TAU, 24, FRAME_COLOR, 2.0)


func _draw_shape(shape: StringName, centre: Vector2, radius: float, colour: Color) -> void:
	match shape:
		&"circle":
			_canvas.draw_circle(centre, radius, colour)
		&"square":
			_canvas.draw_rect(
				Rect2(centre - Vector2(radius, radius), Vector2(radius, radius) * 2.0), colour
			)
		&"diamond":
			var diamond := PackedVector2Array(
				[
					centre + Vector2(0, -radius),
					centre + Vector2(radius, 0),
					centre + Vector2(0, radius),
					centre + Vector2(-radius, 0),
				]
			)
			_canvas.draw_colored_polygon(diamond, colour)
		&"triangle":
			var triangle := PackedVector2Array(
				[
					centre + Vector2(0, -radius),
					centre + Vector2(radius, radius * 0.8),
					centre + Vector2(-radius, radius * 0.8),
				]
			)
			_canvas.draw_colored_polygon(triangle, colour)
		_:
			_canvas.draw_rect(
				Rect2(centre - Vector2(radius * 0.35, radius), Vector2(radius * 0.7, radius * 2.0)),
				colour
			)


func _look(id: StringName) -> Dictionary:
	return LOOK.get(id, DEFAULT_LOOK)


## Prefer dedicated menu art, then accepted object art. Never use player tool-use sheets.
## Missing art stays a shape; unfound items never reveal their painted icon.
func _icon_for(id: StringName) -> Texture2D:
	if not is_found(id):
		return null
	var icon := SpriteVisual.icon_of(StringName("icon_" + String(id)))
	return icon if icon != null else SpriteVisual.icon_of(id)
