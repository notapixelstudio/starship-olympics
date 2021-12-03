extends Control

func _ready():
	$TitleScreen.rect_scale = global.get_graphics_scale()
	Soundtrack.play("Lobby", true)
	# TranslationServer.set_locale("es")
	# Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$Label.text = tr("DEMO BUILD - v"+ str(global.version))
