extends Manager

signal score
func _on_ship_killed(ship : Ship, killer_entity : Entity):
	var killer = killer_entity.get_host()
	
	if killer is Explosion and killer.origin_ship != ship: # duck typing
		emit_signal('score', killer.origin_ship.species, 10)
	else:
		emit_signal('score', ship.species, -10)
		