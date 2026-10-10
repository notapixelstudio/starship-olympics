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

var id: StringName:
	get: return type.id


func is_general() -> bool:
	return type.slot == "general"


## Counts down one played game; false once expired.
func survives_game() -> bool:
	if duration == Duration.RUN:
		return true
	games_left -= 1
	return games_left > 0
