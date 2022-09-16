extends Resource

class_name Minigame

@export var game_mode : Resource

@export_dir var arenas_dir

@export var tutorial_scene : PackedScene

var times_started := 0
# @export_enum('', 'diamond', 'heart', 'snake', 'crown', 'block', 'arrow', 'circle') 
@export var suit_top : String = ''
@export var suit_bottom: String = ''
# @export_enum('', 'diamond', 'heart', 'snake', 'crown', 'block', 'arrow', 'circle') var suit_bottom := 0

func get_id() -> String:
	return str(get_rid().get_id())
	
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
	times_started += 1
	
func is_first_time_started():
	return times_started == 1
	
	
func get_arena_filepath(num_players: int) -> String:
	var dir := Directory.new()
	var file_path = arenas_dir.plus_file(str(num_players) + "players.tscn")
	if num_players <= 1 and not dir.file_exists(file_path):
		file_path = arenas_dir.plus_file("2players.tscn")
	if not dir.file_exists(file_path):
		file_path = arenas_dir.plus_file("234players.tscn")
	if dir.file_exists(file_path):
		return file_path
	else:
		return ""

func get_suit_top() -> String:
	return suit_top

func get_suit_bottom() -> String:
	return suit_bottom

func has_tutorial() -> bool:
	return tutorial_scene != null
	
func get_tutorial_scene() -> PackedScene:
	return tutorial_scene
	
