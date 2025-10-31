extends Node
## Singleton in charge of playing the game's background music.

signal effect_done

## Play the given audio stream, overriding any currently playing audio stream.
func play(audio:AudioStream) -> void:
	%AudioStreamPlayer.stop()
	%AudioStreamPlayer.volume_linear = 1.0
	%AudioStreamPlayer.stream = audio
	%AudioStreamPlayer.play()


func fade_out() -> void:
	await get_tree().create_tween().tween_property(%AudioStreamPlayer, "volume_linear", 0, 2.0).set_ease(Tween.EASE_OUT).finished
	effect_done.emit()
