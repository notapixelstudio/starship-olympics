extends Node

func play(audio:AudioStream) -> void:
	%AudioStreamPlayer.stop()
	%AudioStreamPlayer.stream = audio
	%AudioStreamPlayer.play()
