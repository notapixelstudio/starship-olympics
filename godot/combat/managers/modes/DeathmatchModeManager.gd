extends ModeManager

signal score
func _on_ship_killed(ship : Ship, killer : Ship):
	if not enabled:
		return
		
	if killer and killer.species != ship.species:
		emit_signal('score', killer.species, 8)
	else:
		emit_signal('score', ship.species, -3)
		