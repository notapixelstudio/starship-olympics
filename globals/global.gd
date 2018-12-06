extends Node

const width = 1280
const height = 720

const min_lives = 1
var lives = 5
const max_lives = 10

# levels
var level
var array_level

const SPECIES = ["mantiacs","robolords", "trixens", "another"]
# default unlocked species. The idea is put the locked one to "blank"
var unlocked_species = ["mantiacs","robolords","trixens", "another"]

var from_scene = ProjectSettings.get_setting("application/run/main_scene")

var debug = false

var changed = false

var available_species =[]

var this_run_time = 0

func _ready():
	# get the list of levels
	array_level = dir_contents("res://screens/game_screen/levels")
	if not level:
		level = array_level[randi()%len(array_level)]
	# if we want to save data from global
	add_to_group("persist")
	

func get_state():
	# for debug purposes
	var save_dict = {
		changed=bool(changed),
		level=level
	}
	return save_dict

func load_state(data):
	for attribute in data:
		set(attribute, data[attribute])

func dir_contents(path):
	var dir = Directory.new()
	var list_files = []
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while (file_name != ""):
			if dir.current_is_dir():
				pass
			else:
				if file_name.ends_with(".tscn"):
					list_files.append(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return list_files

# utils
func mod(a,b):
	var ret = a%b
	if ret < 0: 
		return ret+b
	else:
		return ret

func shake_node_backwards(node, tween):
	var actual_d_pos = node.rect_position
	tween.interpolate_method(node, "set_position", node.rect_position, node.rect_position - Vector2(5, 0), 0.05, Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.interpolate_method(node, "set_position", node.rect_position - Vector2(5, 0), actual_d_pos, 0.05, Tween.TRANS_BACK, Tween.EASE_OUT, 0.05)
	tween.start()
	yield(tween,"tween_completed")

func shake_node(node, tween):
	var actual_d_pos = node.rect_position
	tween.interpolate_method(node, "set_position", node.rect_position, node.rect_position + Vector2(5, 0), 0.05, Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.interpolate_method(node, "set_position", node.rect_position + Vector2(5, 0), actual_d_pos, 0.05, Tween.TRANS_BACK, Tween.EASE_OUT, 0.05)
	tween.start()
	yield(tween,"tween_completed")