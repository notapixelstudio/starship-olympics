extends Node

const SETTINGS_FILENAME = "res://export.cfg"

var enable_analytics : bool = false setget _set_analytics

func _set_analytics(new_value):
	enable_analytics = new_value
	GameAnalytics.enabled = enable_analytics

# OPTIONS need a min and a MAX
const min_lives = 1
var lives = 2
const max_lives = 10

# levels
var level
var array_level

var audio_on : bool setget _audio_on

func _audio_on(new_value):
	audio_on = new_value
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), audio_on)
# templates
var templates : Dictionary # {int : Resources}

# DEBUG
var debug : bool = false

# Soundtrack
onready var bgm = Soundtrack
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
const SPECIES_PATH = "res://selection/characters"
var ALL_SPECIES = {
	SPECIES0 = "mantiacs_1",
	SPECIES1 = "robolords_1",
	SPECIES2 = "trixens_1",
	SPECIES3 = "toriels_1",
	SPECIES4 = "takonauts_1",
	SPECIES5 = "mantiacs_2",
	SPECIES6 = "robolords_2",
	SPECIES7 = "trixens_2",
	SPECIES8 = "toriels_2",
	SPECIES9 = "takonauts_2"
}
# dictionary of SPECIES with some values (like a bool unlocked)
var unlocked_species = {
	ALL_SPECIES.SPECIES0: true,
	ALL_SPECIES.SPECIES1: true,
	ALL_SPECIES.SPECIES2: true,
	ALL_SPECIES.SPECIES3 : true,
	ALL_SPECIES.SPECIES4 : true,
	ALL_SPECIES.SPECIES5: true,
	ALL_SPECIES.SPECIES6: false,
	ALL_SPECIES.SPECIES7: true,
	ALL_SPECIES.SPECIES8 : false,
	ALL_SPECIES.SPECIES9 : false
}
var colors = {
	WHITE = Color(1.0, 1.0, 1.0),
	YELLOW = Color(1.0, .757, .027),
	GREEN = Color(.282, .757, .255),
	BLUE = Color(.098, .463, .824),
	PINK = Color(.914, .118, .388)
}
# force saving the game
var force_save = true

# 'from_scene' will have the reference to the previous scene (main scene at the beginning)
var from_scene = ProjectSettings.get_setting("application/run/main_scene")

func _ready():
	print("Starting game...")
	print("FORCE SAVE is ", force_save, " - if true the user file will be overwritten")
	add_to_group("persist")
	
	
	templates = get_species_templates()
	if force_save:
		persistance.save_game()
	if persistance.load_game():
		print("Successfully load the game")
	else:
		print("Something went wrong while loading the game data")
	
	# SET game analytics parameters
	GameAnalytics.base_url = ProjectSettings.get_setting("Analytics/base_url")
	GameAnalytics.game_key = ProjectSettings.get_setting("Analytics/game_key")
	GameAnalytics.secret_key = ProjectSettings.get_setting("Analytics/secret_key")
	GameAnalytics.enabled = enable_analytics
	# END Game Analytics
	if enable_analytics:
		GameAnalytics.request_init()
	
func _exit_tree():
	print("Thanks for playing")
	GameAnalytics.add_to_event_queue(GameAnalytics.get_test_session_end_event(OS.get_ticks_msec()))
	GameAnalytics.submit_events()
	
	

func get_unlocked() -> Dictionary:
	"""
	Get all available unlocked species. 
	@return: Dictionary [enum : resource] that has as keys the enum of the species
	"""
	var available : Dictionary  = {}
	for species in unlocked_species:
		if unlocked_species[species]:
			available[species] = templates[species]
			
	return available

func get_species_templates() -> Dictionary:
	var species_templates = {}
	var resources = dir_contents(SPECIES_PATH, "", ".tres")
	var i = 0
	for species in ALL_SPECIES:
		if i > len(resources) -1:
			pass
			# print("This species: " + species.to_lower(), " is not available")
		else:
			var filename : String = ALL_SPECIES[species] + ".tres"
			species_templates[str(ALL_SPECIES[species])] = load(SPECIES_PATH.plus_file(filename))
			i+=1
	return species_templates


func _unlock_species(species : String):
	unlocked_species[species] = true

# utils
func get_state():
	"""
	get_state will return everything we need to be persistent in the game
	"""
	var save_dict = {
		unlocked_species=unlocked_species,
		enable_analytics=enable_analytics
	}
	return save_dict

func load_state(data:Dictionary):
	"""
	Set back everything we need to load
	"""
	for attribute in data:
		set(attribute, data[attribute])

func dir_contents(path:String, starts_with:String = "", extension:String = ".tscn"):
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
					if not starts_with or file_name.find(starts_with) == 0: 
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
	
func get_base_entity(node : Node):
	if node is Entity:
		return node
	if node == get_node("/root"):
		return null
	if not node:
		return null
	return get_base_entity(node.get_parent())
	