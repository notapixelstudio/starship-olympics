extends Node

func play(player, from_position: float = 0.0) -> void:
	var new_player = player.duplicate()
	add_child(new_player)
	new_player.connect('finished', self, '_on_player_finished', [new_player])
	new_player.play(from_position)
	
func _on_player_finished(player) -> void:
	player.queue_free()
	
