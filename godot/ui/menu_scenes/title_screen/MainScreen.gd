extends Control

export var bgm: AudioStream

func _ready():
	AudioManager.play_bgm(get_bgm())
	# TranslationServer.set_locale("es")
	# Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$Label.text = tr("DEMO BUILD - v"+ str(global.version))
	
	$"%Info".text = "Sessions played: {sessions_played}. Press SHIFT+R to reset".format({"sessions_played": global.sessions_played})

func _process(delta):
	if Input.is_key_pressed(KEY_SHIFT) and Input.is_key_pressed(KEY_R):
		global.sessions_played = 0
		TheUnlocker.unlock_element("starting_decks", "winter", TheUnlocker.LOCKED)
		$"%Info".text = "Sessions played: {sessions_played}. Press SHIFT+R to reset".format({"sessions_played": global.sessions_played})
	
func get_bgm() -> AudioStream:
	return bgm as AudioStream
