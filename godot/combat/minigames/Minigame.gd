extends Resource

class_name Minigame

export var id: String
export var game_mode : Resource

export var level_1players : PackedScene
export var level_2players : PackedScene
export var level_3players : PackedScene
export var level_4players : PackedScene

var new := false

func get_id(): # FIXME? this resource should have its own ID
	return game_mode.get_id()
	
func get_icon():
	return game_mode.get_icon()
	
func get_level(num_players) -> PackedScene:
	return get("level_" + str(num_players) + "players")
	
func get_name():
	return game_mode.name
