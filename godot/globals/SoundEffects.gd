extends Node

func play(player, from_position: float = 0.0) -> void:
	var new_player = player.duplicate()
	add_child(new_player)
	new_player.finished.connect(func(): new_player.queue_free())
	new_player.play(from_position)
	
