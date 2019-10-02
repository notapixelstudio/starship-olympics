extends Manager

signal score
signal show_score

export var max_trail_length: int = 250
export var growth: int = 2

func _on_ship_collided(other : CollisionObject2D, ship : Ship):
	var entity = ECM.E(other)
	
	if not entity:
		return
		
	if entity.has('DashThroughDeadly') and not (ECM.E(ship).has('Dashing')):
		var killer = entity.get('Owned').get_owned_by()
		if killer != ship or not entity.has("NoSelfDeadly"):
			ship.die(killer)

func _process(delta):
	for trail in get_tree().get_nodes_in_group("Trails"):
		trail.trail_f += growth * delta
		trail.trail_length = min(trail.trail_f, max_trail_length)