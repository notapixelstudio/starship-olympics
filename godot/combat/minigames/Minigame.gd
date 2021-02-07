extends Resource

class_name Minigame

export var game_mode : Resource

export var level_1players : PackedScene
export var level_2players : PackedScene
export var level_3players : PackedScene
export var level_4players : PackedScene

func get_id():
	return game_mode.get_id()
	
func get_icon():
	return game_mode.get_icon()
	
