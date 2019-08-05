extends ModeManager

signal score
signal show_score

func _on_ship_killed(ship : Ship, killer : Ship):
	if not enabled:
		return
		
	if killer and killer.species != ship.species:
		emit_signal('score', killer.species, score_multiplier)
		emit_signal('show_score', killer.species_template, score_multiplier, ship.position)
		