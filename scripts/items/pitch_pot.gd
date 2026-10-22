extends ItemBase
## Pitch pot (bomb). Placed one tile in front of the player, explodes after FUSE seconds.
##
## The blast is a NEUTRAL hitbox (enemies take DAMAGE, the player DAMAGE_VS_PLAYER through the
## normal hit system, so i-frames apply), an Events.explosion and an on_explosion() call on every
## node in group "explodable" (cracked walls). Max MAX_ON_SCREEN pots at a time; each use spends
## one pitch pot from GameState.

const FUSE := 1.6
const RADIUS := 150.0
const TILE := 96.0
const MAX_ON_SCREEN := 2
const DAMAGE := 4
const DAMAGE_VS_PLAYER := 2
const BLAST_TIME := 0.1

var _armed: bool = false
var _exploded: bool = false
var _fuse: float = FUSE
var _blast_left: float = 0.0
var _blink_left: float = 0.0


func _init() -> void:
	item_id = &"pitch_pot"


func _ready() -> void:
	Placeholder.attach(self, &"pitch_pot")


## Refuses at the on-screen limit or with no pitch pots left. The limit is checked first so a
## refused use does not spend ammo.
func activate() -> bool:
	if active_count() > MAX_ON_SCREEN:
		return false
	if not GameState.spend_pitch_pot():
		return false
	if player != null:
		global_position = player.global_position + facing * TILE
	_armed = true
	return true


func _physics_process(delta: float) -> void:
	if not _armed:
		return
	if not _exploded:
		_fuse -= delta
		_blink(delta)
		if _fuse <= 0.0:
			_explode()
		return
	_blast_left -= delta
	if _blast_left <= 0.0:
		finish()


## Visual only: the fuse blinks faster as it burns down.
func _blink(delta: float) -> void:
	_blink_left -= delta
	if _blink_left > 0.0:
		return
	var progress := clampf(1.0 - _fuse / FUSE, 0.0, 1.0)
	_blink_left = lerpf(0.3, 0.05, progress)
	var visual := get_node_or_null(Placeholder.VISUAL_NAME) as CanvasItem
	if visual != null:
		visual.visible = not visual.visible


func _explode() -> void:
	_exploded = true
	_blast_left = BLAST_TIME
	var at := global_position
	var blast := Hitbox.new()
	blast.name = "Blast"
	blast.team = Layers.Team.NEUTRAL
	blast.kind = &"explosion"
	blast.damage = DAMAGE
	blast.damage_vs_player = DAMAGE_VS_PLAYER
	blast.source = self
	blast.add_circle(RADIUS)
	add_child(blast)
	blast.activate()
	var visual := get_node_or_null(Placeholder.VISUAL_NAME) as CanvasItem
	if visual != null:
		visual.visible = false
	var parent := get_parent()
	if parent != null:
		Placeholder.puff(parent, at, Placeholder.color_of(&"explosion"), RADIUS)
	Events.explosion.emit(at, RADIUS)
	for node in get_tree().get_nodes_in_group(&"explodable"):
		if node.has_method(&"on_explosion"):
			node.call(&"on_explosion", at, RADIUS)
