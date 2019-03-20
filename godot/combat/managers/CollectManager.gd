extends Manager

func ship_near_area_entered(other : CollisionObject2D, ship : Ship):
	var entity = ECM.E(other)
	
	if not entity:
		return
		
	if entity.has('Collectable') and ship.is_alive():
		entity.get('Collectable').disable() # this makes sure we don't enter here twice
		
		# FIXME: this assumes the only collectable item is the Crown
		ECM.E(ship).get('Royal').enable() # move in a suitable manager
		
		entity.get_host().call_deferred("queue_free") # move in arena?
		