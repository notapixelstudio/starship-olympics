extends Manager

func ship_collided(ship : Ship, other : CollisionObject2D):
	var entity = ECM.E(other)
	
	if not entity:
		return
		
	if entity.has('Stunning'):
		ship.stun()
		