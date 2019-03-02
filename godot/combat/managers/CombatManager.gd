extends Manager

func ship_near_area_entered(other : CollisionObject2D, ship : Ship):
	var entity = ECM.E(other)
	
	if not entity:
		return
		
	if entity.has('Deadly'):
		ship.die()
		