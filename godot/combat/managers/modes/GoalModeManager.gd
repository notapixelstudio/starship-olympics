extends ModeManager

signal show_msg

func _on_goal_done(ship):
	if not enabled:
		return
	.score(ship.get_id(), score_multiplier)
	emit_signal('show_msg', ship.species, score_multiplier, ship.position)
	
