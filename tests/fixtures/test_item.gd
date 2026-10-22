extends ItemBase
## Test fixture: a sub-item that records its use and refuses a second simultaneous instance.

static var activations: int = 0


func _init() -> void:
	item_id = &"test_item"


func activate() -> bool:
	if active_count() > 1:
		return false
	activations += 1
	return true
