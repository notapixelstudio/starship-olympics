extends Node

const SPECIES_PATH = "res://selection/characters"
# playtest mode, fixed selection player
var demo_playtest : bool = false

@onready var species_resources: Dictionary = Utils.get_resources(SPECIES_PATH)

func get_species(species_id: String):
	return species_resources[species_id]


const LANGUAGES = {
	"español": "es",
	"english": "en",
	"italiano": "it",
	"euskara": "eu",
	"français": "fr",
	"deutsch": "de",
	"alien": "pr"
}
var language : String = 'english' : set = _set_language
var fullscreen : bool = true : set = _set_fullscreen
var master : int = 100 : set = _set_master
var music : int = 100 : set = _set_music
var sfx : int = 100 : set = _set_sfx

func _ready() -> void:
	add_to_group("persist")
	
	if persistance.load_game():
		print("Successfully load the game")
	else:
		print("Something went wrong while loading the game data")

func _set_language(value: String):
	language = value
	TranslationServer.set_locale(LANGUAGES.get(value, "english"))
	Events.language_changed.emit()

func _set_fullscreen(value: bool):
	fullscreen = value
	var mode_to_be = Window.MODE_EXCLUSIVE_FULLSCREEN if (fullscreen) else Window.MODE_WINDOWED
	if get_window().mode != mode_to_be:
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (fullscreen) else Window.MODE_WINDOWED
		get_window().move_to_foreground()
	if fullscreen:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
func toggle_fullscreen() -> void:
	_set_fullscreen(not fullscreen)
	
func _set_master(value: int):
	master = value
	var db_volume = linear_to_db(float(value)/100)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index('Master'), db_volume)

func _set_music(value: int):
	music = value
	var db_volume = linear_to_db(float(value)/100)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index('Music'), db_volume)

func _set_sfx(value: int):
	sfx = value
	var db_volume = linear_to_db(float(value)/100)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index('SFX'), db_volume)


func get_state():
	"""
	get_state will return everything we need to be persistent in the game
	"""
	return {
		language=language,
		fullscreen=fullscreen,
		master=master,
		sfx=sfx,
		music=music
	}
	

func load_state(data:Dictionary):
	"""
	Set back everything we need to load
	"""
	for attribute in data:
		set(attribute, data[attribute])



func get_ordered_species() -> Array:
	var ordered_species = []
	var unlocked_species = TheUnlocker.get_unlocked_list("species")
	for species_id in unlocked_species:
		ordered_species.append(get_species(species_id))
	ordered_species.sort_custom(Callable(self, 'compare_by_species_id'))
	return ordered_species

func compare_by_species_id(a: Species, b: Species):
	return a.species_id < b.species_id
