extends Resource

class_name Minigame

@export var game_mode : Resource

@export var arenas_dir: String

@export var tutorial_scene : PackedScene

var id = null
var times_started := 0

@export_enum("blue", "white", "cyan", "red", "yellow", 'green', "magenta") var suit_top = ''
@export_enum("blue", "white", "cyan", "red", "yellow", 'green', "magenta") var suit_bottom = ''

func get_id() -> String:
	if id != null:
		return id
	else:
		return self.resource_path.get_basename().get_file()
	
func get_logo():
	return game_mode.get_icon()
	
func get_icon():
	return game_mode.get_icon()
	
func get_level(num_players) -> Resource:
	var filepath: String = self.get_arena_filepath(num_players)
	return load(filepath)
	
func get_name():
	return game_mode.name
	
func get_description():
	return game_mode.description

func increase_times_started():
	if global.demo:
		return
	times_started += 1
	
func is_first_time_started():
	return times_started == 1
	
func reset_count():
	times_started = 0

func get_arena_filepath(num_players: int) -> String:
	
	var file_path = arenas_dir.path_join(str(num_players) + "players.tscn")
	if num_players <= 1 and not FileAccess.file_exists(file_path):
		file_path = arenas_dir.path_join("2players.tscn")
	if not FileAccess.file_exists(file_path):
		file_path = arenas_dir.path_join("234players.tscn")
	if FileAccess.file_exists(file_path):
		return file_path
	else:
		return ""

func get_suit_top() -> Array:
	return suit_top

func get_suit_bottom() -> Array:
	return suit_bottom

func has_tutorial() -> bool:
	return tutorial_scene != null
	
func get_tutorial_scene():
	var filepath: String = arenas_dir.path_join("TutorialArena.tscn")
	return load(filepath)
