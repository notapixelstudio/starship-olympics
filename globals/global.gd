extends Node

# OPTIONS need a min and a MAX
const MINLIVES = 1
var lives = 5
const MAXLIVES = 10

# levels
var level
var array_level

# Controls
enum Controls {KB1, KB2, JOY1, JOY2, JOY3, JOY4, NO, CPU}

const CONTROLSMAP = {
	Controls.NO : "no",
	Controls.CPU : "cpu",
    Controls.KB1 : "kb1",
    Controls.KB2 : "kb2",
    Controls.JOY1 : "joy1",
    Controls.JOY2 : "joy2",
    Controls.JOY3 : "joy3",
    Controls.JOY4 : "joy4"
}

const CONTROLSMAP_TO_KEY = {
	"no" : Controls.NO,
	"cpu" : Controls.CPU,
    "kb1" : Controls.KB1,
    "kb2" : Controls.KB2,
    "joy1" : Controls.JOY1,
    "joy2" : Controls.JOY2,
    "joy3" : Controls.JOY3,
    "joy4" : Controls.JOY4
}

const MAX_PLAYERS = 4

# Species handler
const SPECIES_PATH = "res://selection/species"
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

# 'from_scene' will have the reference to the previous scene (main scene at the beginning)
var from_scene = ProjectSettings.get_setting("application/run/main_scene")

func get_unlocked() -> Dictionary:
	"""
	Get all available unlocked species, and return a dictionary that has as keys the enum of the species
	"""
	var available : Dictionary  = {}
	for species in unlocked_species:
		if unlocked_species[species]:
			available[species] = {}
			
	return available

func get_species_templates() -> Dictionary:
	var species_templates = {}
	var resources = dir_contents(SPECIES_PATH, ".tres")
	var i = 0
	for species in ALL_SPECIES:
		if i > len(resources) -1:
			print("This species: " + species.to_lower(), " is not available")
		else:
			species_templates[ALL_SPECIES[species]] = load(SPECIES_PATH.plus_file(resources[i]))
			i+=1
	return species_templates


func _unlock_species(species : String):
	unlocked_species[species] = true

func _ready():
	add_to_group("persist")
	print(ALL_SPECIES)
	print(ALL_SPECIES.keys()[1])
	print(get_species_templates())
	if force_save:
		persistance.save_game()
	persistance.load_game()

# utils
func get_state():
	"""
	get_state will return everything we need to be persistent in the game
	"""
	var save_dict = {
		unlocked_species=unlocked_species,
		level=level
	}
	return save_dict

func load_state(data:Dictionary):
	"""
	Set back everything we need to load
	"""
	for attribute in data:
		set(attribute, data[attribute])

func dir_contents(path:String, extension:String = ".tscn"):
	"""
	@param path:String given the path 
	@return a list of filename
	"""
	var dir = Directory.new()
	var list_files = []
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while (file_name != ""):
			if dir.current_is_dir():
				pass
			else:
				if file_name.ends_with(extension):
					list_files.append(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return list_files

func mod(a,b):
	"""
	Modulus: Maybe fposmod and fmod will do the trick by its own
	"""
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