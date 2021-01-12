extends ModeManager

func _process(delta):
	if not enabled:
		return
		
	for ship in get_tree().get_nodes_in_group('players'):
		if ship.alive:
			.score(ship.get_id(), delta)
