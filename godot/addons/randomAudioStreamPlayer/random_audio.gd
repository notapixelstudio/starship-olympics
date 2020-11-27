tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("RandomAudioStreamPlayer", "AudioStreamPlayer", preload("random_audio_stream_player.gd"), preload("icon_random_audio_stream_player.svg"))
	add_custom_type("RandomAudioStreamPlayer2D", "AudioStreamPlayer2D", preload("random_audio_stream_player_2D.gd"), preload("icon_random_audio_stream_player_2_d.svg"))
	add_custom_type("RandomAudioStreamPlayer3D", "AudioStreamPlayer3D", preload("random_audio_stream_player_3D.gd"), preload("icon_random_audio_stream_player_3_d.svg"))

func _exit_tree():
	remove_custom_type("RandomAudioStreamPlayer")
	remove_custom_type("RandomAudioStreamPlayer2D")
	remove_custom_type("RandomAudioStreamPlayer3D")
