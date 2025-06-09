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
		
