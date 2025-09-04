extends Node

var _royalnesses := {}

func _physics_process(delta: float) -> void:
	# assign points
	for ship in get_tree().get_nodes_in_group('Ship'):
		if ship.get_cargo_manager().get_cargo() is Crown:
			if not ship in _royalnesses:
				_royalnesses[ship] = 0.0
				
			Events.points_scored.emit(delta, ship.get_team())
			_royalnesses[ship] += delta
			var msg = str("+%0.2f" % _royalnesses[ship])
			ship.set_message(msg)
			
		elif ship in _royalnesses:
			Events.message.emit(_royalnesses[ship], ship.get_color(), ship.global_position + Vector2(0,-150))
			_royalnesses.erase(ship)
			ship.set_message('')
	
func _on_match_over(data:Dictionary) -> void:
	set_physics_process(false)
