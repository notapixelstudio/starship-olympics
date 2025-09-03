extends Node

func _physics_process(delta: float) -> void:
	# assign points
	for ship in get_tree().get_nodes_in_group('Ship'):
		if ship.get_cargo_manager().get_cargo() is Crown:
			Events.points_scored.emit(delta, ship.get_team())
	
func _on_match_over(data:Dictionary) -> void:
	set_physics_process(false)
