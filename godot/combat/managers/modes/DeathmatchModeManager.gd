extends ModeManager

signal score
signal broadcast_score
signal show_score

func _on_ship_killed(ship : Ship, killer : Ship):
	if not enabled:
		return
	
	if killer == ship:
		emit_signal("broadcast_score", killer.species, score_multiplier)
		
	elif killer and killer.species != ship.species:
		emit_signal('score', killer.species, score_multiplier)
		emit_signal('show_score', killer.species_template, score_multiplier, ship.position)
		
