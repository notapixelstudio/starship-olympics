extends Trait

## this is used by the level designer to indicate which player this ownership trait will be
## assigned to - players and ships are not there yet when a level is designed, so a home
## is assigned instead
@export var player_homes : Array[Home]
var _players : Array[Player]

## check if the given [class Home] is linked to this ownership trait
func has_home(home:Home) -> bool:
	return home in player_homes

func add_player(p:Player) -> void:
	_players.append(p)
	
func get_players() -> Array[Player]:
	return _players
