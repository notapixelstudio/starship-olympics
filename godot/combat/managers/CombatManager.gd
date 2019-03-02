extends Manager

func ship_near_area_entered(other : CollisionObject2D, ship : Ship):
	var entity = ECM.E(other)
	
	if not entity:
		return
		
	if entity.has('Deadly'):
		ship.die()
		
func bomb_near_area_entered(other : CollisionObject2D, bomb : Bomb):
	var entity = ECM.E(other)
	
	if not entity:
		return
		
	if entity.has('Trigger'):
		bomb.detonate()
		
func ship_within_detection_distance(other : CollisionObject2D, ship : Ship):
	var entity = ECM.E(other)
	
	if not entity:
		return
		
	if entity.has('Detector'):
		# duck typing: detector entities must implement try_acquire_target()
		# FIXME should all the detection logic be moved here?
		entity.get_host().try_acquire_target(ship)
		