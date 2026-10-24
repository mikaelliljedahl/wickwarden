extends VBoxContainer
## Vertical text menu for the title screen and its prompts (F13). Entries are dictionaries
## {id, label, enabled}. Move up or left selects the previous enabled entry, move down or right the
## next one. Both wrap around and skip disabled entries. `confirm` or `ui_accept` emits `activated(id)`.
## The selected entry is drawn in the accent colour, a disabled one muted. Placeholder look: text only.
## No button help here: that lives only in the pause menu.

signal activated(id: StringName)

const FONT_SIZE := 52
const SEPARATION := 22
const MARK := "> "
const TEXT_COLOR := Color(0.92, 0.88, 0.78)
const SELECT_COLOR := Color(1.0, 0.85, 0.4)
const MUTED_COLOR := Color(0.42, 0.42, 0.46)

var _entries: Array = []
var _labels: Array = []
var _selected: int = -1


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_constant_override("separation", SEPARATION)


## Replaces the entries. The first enabled entry becomes the selection.
func set_entries(entries: Array) -> void:
	for label: Label in _labels:
		remove_child(label)
		label.queue_free()
	_labels.clear()
	_entries = entries.duplicate(true)
	for entry: Dictionary in _entries:
		var label := Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", FONT_SIZE)
		add_child(label)
		_labels.append(label)
	_selected = _find(-1, 1)
	_refresh()


## Every entry id in order, enabled or not.
func ids() -> Array:
	var result: Array = []
	for entry: Dictionary in _entries:
		result.append(entry["id"])
	return result


## The selected entry id, or &"" when no entry is enabled.
func selected_id() -> StringName:
	if _selected < 0:
		return &""
	return _entries[_selected]["id"]


func is_enabled(id: StringName) -> bool:
	var index := _index_of(id)
	return index >= 0 and _entries[index]["enabled"]


## Enables or disables an entry. A disabled selection moves on to the next enabled entry; an enabled
## entry is selected when nothing was.
func set_enabled(id: StringName, value: bool) -> void:
	var index := _index_of(id)
	if index < 0:
		return
	_entries[index]["enabled"] = value
	if not value and index == _selected:
		_selected = _find(index, 1)
	elif value and _selected < 0:
		_selected = index
	_refresh()


## Selects an enabled entry. False, and no change, for an unknown or disabled id.
func select(id: StringName) -> bool:
	var index := _index_of(id)
	if index < 0 or not _entries[index]["enabled"]:
		return false
	_selected = index
	_refresh()
	return true


## Moves the selection by one enabled entry: -1 is the previous one, 1 the next one. Wraps around.
func move(step: int) -> void:
	_selected = _find(_selected, step)
	_refresh()


## Handles one input event. True when it was a menu key, so the caller can consume it.
func handle_input(event: InputEvent) -> bool:
	if event.is_action_pressed(&"confirm") or event.is_action_pressed(&"ui_accept"):
		var id := selected_id()
		if id != &"":
			activated.emit(id)
		return true
	if event.is_action_pressed(&"move_up", true) or event.is_action_pressed(&"move_left", true):
		move(-1)
		return true
	if event.is_action_pressed(&"move_down", true) or event.is_action_pressed(&"move_right", true):
		move(1)
		return true
	return false


## The next enabled entry after `from` in direction `step` (wraps). -1 when none is enabled.
func _find(from: int, step: int) -> int:
	var count := _entries.size()
	if count == 0:
		return -1
	for offset in range(1, count + 1):
		var index := posmod(from + step * offset, count)
		if _entries[index]["enabled"]:
			return index
	return -1


func _index_of(id: StringName) -> int:
	for index in _entries.size():
		if _entries[index]["id"] == id:
			return index
	return -1


func _refresh() -> void:
	for index in _labels.size():
		var entry: Dictionary = _entries[index]
		var label: Label = _labels[index]
		var text: String = entry["label"]
		var colour := TEXT_COLOR
		if not entry["enabled"]:
			colour = MUTED_COLOR
		if index == _selected:
			text = MARK + text
			colour = SELECT_COLOR
		label.text = text
		label.add_theme_color_override("font_color", colour)
