extends Node
## Singleton in charge of playing the game's background music.


## Play the given audio stream, overriding any currently playing audio stream.
func play(audio:AudioStream) -> void:
	%AudioStreamPlayer.stop()
	%AudioStreamPlayer.stream = audio
	%AudioStreamPlayer.play()
