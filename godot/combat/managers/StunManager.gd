extends Manager

func ship_collided(other : CollisionObject2D, ship : Ship):
	var entity = ECM.E(other)
	
	if not entity:
		return
		
	if entity.has('Stunning'):
		ship.stun()
		
