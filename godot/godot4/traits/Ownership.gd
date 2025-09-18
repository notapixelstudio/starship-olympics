extends Trait

@export var player_homes : Array[Home]
var _players : Array[Player]

func has_home(home:Home) -> bool:
	return home in player_homes

func add_player(p:Player) -> void:
	_players.append(p)
	
func get_players() -> Array[Player]:
	return _players
