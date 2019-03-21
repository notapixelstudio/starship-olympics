extends Manager

signal score
func _on_ship_killed(ship : Ship, killer : Ship):
	if killer and killer.species != ship.species:
		emit_signal('score', killer.species, 5)
	else:
		emit_signal('score', ship.species, -5)
		