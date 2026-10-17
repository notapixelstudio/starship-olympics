class_name Item extends Resource
## A variant of an [ItemType]: how long it lasts and whether it is glass.
## Create it inline wherever it is given (a Collectable, a zone, a character...), no file needed.

## How many games it lasts; RUN lasts the whole run.
enum Duration { RUN = 0, GAME = 1, TWO_GAMES = 2 }

@export var type: ItemType
@export var duration := Duration.GAME
## Glass items shatter when their holder's ship is disabled.
@export var glass := false

## Games left for a granted copy, see [method Session.grant_item].
@export_storage var games_left := 0

## This is currently relevant for [Cargo], set by the cargo itself (in order to avoid 
## recursive thingy. Crown and GlassCrown share the same type
var _element_scene: PackedScene

func _init() -> void:
	resource_local_to_scene = true

func get_type_id() -> StringName:
	return type.id

func is_cargo() -> bool:
	return type.is_cargo()

func get_element_scene() -> PackedScene:
	return _element_scene
	
func _to_string() -> String:
	return "%s%s (%s)" % [type.id, ' (Glass)' if glass else '', duration]

func is_general() -> bool:
	return type.slot == "general"

func is_glass() -> bool:
	return glass
	
## Counts down one played game; false once expired.
func survives_game() -> bool:
	if duration == Duration.RUN:
		return true
	games_left -= 1
	return games_left > 0

func set_element_scene(scene:PackedScene) -> void:
	_element_scene = scene
