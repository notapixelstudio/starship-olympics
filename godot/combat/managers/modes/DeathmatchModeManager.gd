extends ModeManager

signal score
signal broadcast_score
signal show_score

func _on_ship_killed(ship : Ship, killer : Ship):
	if not enabled:
		return
	
	if not killer or killer == ship:
		emit_signal("broadcast_score", ship.get_id(), score_multiplier)
		
	elif killer and killer.species != ship.species:
		emit_signal('score', killer.get_id(), score_multiplier)
		emit_signal('show_score', killer.species, score_multiplier, ship.position)
		
