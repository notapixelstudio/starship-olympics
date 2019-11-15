extends Node

const SETTINGS_FILENAME = "res://export.cfg"
const E = 2.71828

var enable_analytics : bool = false setget _set_analytics
signal send_statistics

func _set_analytics(new_value):
	enable_analytics = new_value
	GameAnalytics.build_version = version
	GameAnalytics.enabled = enable_analytics
	connect("send_statistics", GameAnalytics, "add_event")

var available_languages = {
	"english": "en",
	"español": "es",
	"italiano": "it",
	"euskara": "eu",
	"français": "fr",
	"deutsch": "de"
	}
onready var language: String setget _set_language, _get_language
var array_language: Array = ["english", "italiano", "español", "euskara", "français", "deutsch"]

func _set_language(value:String):
	language = value
	TranslationServer.set_locale(available_languages[language])

func _get_language():
	return language

var version = "0.5.0"

# OPTIONS need a min and a MAX
const min_win = 1
var win = 3
const max_win = 5

# levels
var level
var array_level

var audio_on : bool setget _audio_on

var demo : bool = true

func _audio_on(new_value):
	audio_on = new_value
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), audio_on)

var master_volume : int setget _set_master_volume
var min_master_volume : int = 0
var max_master_volume: int = 100

func _set_master_volume(new_value): 
	master_volume = new_value
	var db_volume = linear2db(float(new_value)/100)
	var bus_name = "Master"
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), db_volume)
	print(bus_name, " set at ", str(db_volume), " that is ", str(new_value))

var music_volume : int setget _set_music_volume
var min_music_volume : int = 0
var max_music_volume: int = 100

func _set_music_volume(new_value): 
	music_volume = new_value
	var db_volume = linear2db(float(new_value)/100)
	var bus_name = "Music"
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), db_volume)
	print(bus_name, " set at ", str(db_volume), " that is ", str(new_value))
	
var sfx_volume : int setget _set_sfx_volume
var min_sfx_volume : int = 0
var max_sfx_volume: int = 100

func _set_sfx_volume(new_value): 
	sfx_volume = new_value
	var db_volume = linear2db(float(sfx_volume)/100)
	var bus_name = "SFX"
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), db_volume)
	print(bus_name, " set at ", str(db_volume), " that is ", str(new_value))

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

# 'from_scene' will have the reference to the previous scene (main scene at the beginning)
var from_scene = ProjectSettings.get_setting("application/run/main_scene")

func _input(event):
	if event.is_action_pressed("fullscreen"):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		OS.window_fullscreen = not OS.window_fullscreen
		
func _ready():
	print("Starting game...")
	add_to_group("persist")
	
	#setup language
	var generic_locale = TranslationServer.get_locale().split("_")[0]
	language = TranslationServer.get_locale_name(generic_locale).to_lower()
	
	templates = get_species_templates()
	var saved_data = persistance.get_saved_data()
	var k = get_path()
	var global_key = String(get_path())
	
	if not saved_data or not "version" in saved_data[global_key] or check_version(saved_data[global_key]["version"], version):
		print("We need to update the saved game")
		persistance.save_game()
		
	if persistance.load_game():
		print("Successfully load the game")
	else:
		print("Something went wrong while loading the game data")
	

func end_game():
	print("Thanks for playing")
	GameAnalytics.end_session()
	if global.enable_analytics:
		yield(GameAnalytics, "message_sent")
	get_tree().quit()

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
		win=win,
		unlocked_species=unlocked_species,
		enable_analytics=enable_analytics,
		language=language,
		version=version,
		music_volume=music_volume,
		master_volume=master_volume,
		sfx_volume=sfx_volume,
		demo=demo
		
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
	
func check_version(saved_version: String, version: String):
	# Will check if the version of the saved data is smaller the current
	var this_minor = saved_version.split(".")[1]
	var minor = version.split(".")[1]
	print(this_minor, " vs ", minor)
	return this_minor < minor

func send_stats(category: String, stats: Dictionary):
	emit_signal("send_statistics", category, stats)
		
func sigmoid(x, width):
	return 1-1/(1+pow(E, -10*(x/width-0.5)))
	
