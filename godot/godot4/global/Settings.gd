extends Node

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
var master : int = 50 : set = _set_master
var music : int = 50 : set = _set_music
var sfx : int = 50 : set = _set_sfx

func _set_language(value: String):
	language = value
	TranslationServer.set_locale(LANGUAGES.get(value, "english"))
	Events.language_changed.emit()

func _set_fullscreen(value: bool):
	fullscreen = value
	get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (fullscreen) else Window.MODE_WINDOWED
	get_window().move_to_foreground()
	if fullscreen:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
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
