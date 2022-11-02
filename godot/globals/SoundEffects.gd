extends Node

func play(player, from_position: float = 0.0):
	var new_player = player.duplicate()
	add_child(new_player)
	new_player.play(from_position)
	yield(new_player, 'finished')
	new_player.queue_free()
	
