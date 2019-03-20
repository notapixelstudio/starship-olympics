extends Manager

signal score
func _on_ship_near_area_entered(other : CollisionObject2D, ship : Ship):
	var entity = ECM.E(other)
	
	if not entity:
		return
		
	if entity.has('Deadly'):
		if entity.get_host() is Explosion and entity.get_host().origin_ship != ship: # duck typing
			emit_signal('score', entity.get_host().origin_ship.species, 10)
		else:
			emit_signal('score', ship.species, -10)
			