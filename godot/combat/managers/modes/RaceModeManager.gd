extends ModeManager

const LAP_SCORE = 10

signal show_msg

func _on_lap_done(ship, portal):
	if not enabled:
		return
	var score = score_multiplier
	if portal.inverted:
		score = -score
	.score(ship.get_id(), score)
	emit_signal('show_msg', ship.species, score, ship.position)
	
