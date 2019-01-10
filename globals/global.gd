extends Node

const min_lives = 1
var lives = 5
const max_lives = 10

# levels
var level
var array_level

const MAX_PLAYERS = 4
const SPECIES = ["mantiacs", "robolords", "trixens", "anothers"]

# dictionary of SPECIES with some values (like a bool unlocked)
var unlocked_species = {
	"mantiacs": true,
	"robolords": true,
 	"trixens": true,
	"anothers" : true
}

var debug = false
var this_run_time = 0

# force saving the game
var force_save = true
var from_scene = ProjectSettings.get_setting("application/run/main_scene")

func get_unlocked() -> Dictionary:
	var available : Dictionary  = {}
	var i = 1
	for species in SPECIES:
		if unlocked_species[species]:
			available[species] = i
			i+=1
	return available

func _unlock_species(species : String):
	unlocked_species[species] = true

func _ready():
	add_to_group("persist")
	if persistance.load_game() and not force_save:
		return
	
	for this_species in SPECIES:
		unlocked_species[this_species] = true
	persistance.save_game()
	

# utils
func get_state():
	# for debug purposes
	var save_dict = {
		unlocked_species=unlocked_species,
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