extends Resource

class_name Minigame

export var game_mode : Resource

export var level_1players : PackedScene
export var level_2players : PackedScene
export var level_3players : PackedScene
export var level_4players : PackedScene

export var tutorial_scene : PackedScene

var times_started := 0

export (String, '', 'diamond', 'heart', 'snake', 'crown', 'block', 'arrow', 'circle') var suit_top = ''
export (String, '', 'diamond', 'heart', 'snake', 'crown', 'block', 'arrow', 'circle') var suit_bottom = ''


func get_id() -> String:
	return str(get_rid().get_id())
	
func get_icon():
	return game_mode.get_icon()
	
func get_level(num_players) -> PackedScene:
	return get("level_" + str(num_players) + "players")
	
func get_name():
	return game_mode.name
	
func get_description():
	return game_mode.description

func increase_times_started():
	times_started += 1
	
func is_first_time_started():
	return times_started == 1
	
func has_level_for_player_count(player_count: int) -> bool:
	return get("level_"+str(player_count)+"players") != null
	
func get_available_player_counts() -> Array:
	var possible_player_counts := [1,2,3,4]
	var player_counts := []
	for player_count in possible_player_counts:
		if has_level_for_player_count(player_count):
			player_counts.append(player_count)
	return player_counts

func get_suit_top() -> Array:
	return suit_top

func get_suit_bottom() -> Array:
	return suit_bottom

func has_tutorial() -> bool:
	return tutorial_scene != null
	
func get_tutorial_scene() -> PackedScene:
	return tutorial_scene
	
