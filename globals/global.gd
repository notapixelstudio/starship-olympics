extends Node

const min_lives = 1
var lives = 5
const max_lives = 10

# levels
var level
var array_level

const MAX_PLAYERS = 4
const max_species = 5
enum ALL_SPECIES {SPECIES0, SPECIES1, SPECIES2, SPECIES3, SPECIES4}


# dictionary of SPECIES with some values (like a bool unlocked)
var unlocked_species = {
	ALL_SPECIES.SPECIES0: true,
	ALL_SPECIES.SPECIES1: true,
	ALL_SPECIES.SPECIES2: true,
	ALL_SPECIES.SPECIES3 : true,
	ALL_SPECIES.SPECIES4 : false
}

# force saving the game
var force_save = true
var from_scene = ProjectSettings.get_setting("application/run/main_scene")

func get_unlocked() -> Dictionary:
	"""
	Get all available unlocked species, and return a dictionary that has as keys the enum of the species
	"""
	var available : Dictionary  = {}
	var i = 1
	for species in unlocked_species:
		if unlocked_species[species]:
			available[species] = {}
			i+=1
	return available

func _unlock_species(species : String):
	unlocked_species[species] = true

func _ready():
	add_to_group("persist")
	print(ALL_SPECIES)
	if force_save:
		persistance.save_game()
	persistance.load_game()
	

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
				continue
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