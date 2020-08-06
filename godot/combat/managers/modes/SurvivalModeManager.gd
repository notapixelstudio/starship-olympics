extends ModeManager

signal score

func _process(delta):
	if not enabled:
		return
		
	for ship in get_tree().get_nodes_in_group('players'):
		if ship.alive:
			emit_signal('score', ship.get_id(), delta)
			
