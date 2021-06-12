extends Node

func start():
	# listen to all ships
	for ship in get_tree().get_nodes_in_group('player_ship'):
		ship.connect('body_entered', self, '_on_ship_collided', [ship])
		
func _on_ship_collided(other, ship):
	assert(ship is Ship)
	if not(other is Ship):
		return
	
	# avoid scoring twice per collision
	if ship.get_id() < other.get_id():
		return
	
	global.the_match.add_score(ship.get_id(), 1)
	global.arena.show_msg(ship.species, 1, ship.position)
	global.the_match.add_score(other.get_id(), 1)
	global.arena.show_msg(other.species, 1, other.position)
	
