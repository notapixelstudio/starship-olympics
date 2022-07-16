extends Resource

class_name Minigame

export var id: String
export var game_mode : Resource

export var level_1players : PackedScene
export var level_2players : PackedScene
export var level_3players : PackedScene
export var level_4players : PackedScene

var new := false

var times_started := 0
var strikes := 0

func get_id(): # FIXME? this resource should have its own ID
	return game_mode.get_id()
	
func get_icon():
	return game_mode.get_icon()
	
func get_level(num_players) -> PackedScene:
	return get("level_" + str(num_players) + "players")
	
func get_name():
	return game_mode.name

func increase_times_started():
	times_started += 1
	
func is_first_time_started():
	return times_started == 1
	
func take_strike():
	strikes += 1
	
func has_enough_strikes() -> bool:
	return strikes >= 3
	
