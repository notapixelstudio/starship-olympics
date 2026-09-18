extends Trait

@export var player : Player

## this is used by the level designer to indicate which player this ownership trait will be
## assigned to - players and ships are not there yet when a level is designed, so a home
## is assigned instead
@export var player_home : Home


## check if the given [class Home] is linked to this ownership trait
func has_home(home:Home) -> bool:
	return home == player_home
	
func set_player(v: Player) -> void:
	player = v
	
func get_player() -> Player:
	return player
