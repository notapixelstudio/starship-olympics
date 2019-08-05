extends Manager

signal score
signal show_score

func _on_ship_collided(other : CollisionObject2D, ship : Ship):
	var entity = ECM.E(other)
	
	if not entity:
		return
		
	if entity.has('DashThroughDeadly') and not (ECM.E(ship).has('Dashing')):
		var killer = entity.get('Owned').get_owned_by()
		ship.die(killer)
		