extends ModeManager

signal score
signal show_score

func _on_goal_done(ship):
	if not enabled:
		return
	
	emit_signal('score', ship.get_id(), score_multiplier)
	emit_signal('show_score', ship.species, score_multiplier, ship.position)
	