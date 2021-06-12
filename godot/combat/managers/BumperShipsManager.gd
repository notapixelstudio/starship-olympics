extends Node

func start():
	# listen to all ships
	for ship in get_tree().get_nodes_in_group('player_ship'):
		ship.connect('bump', self, '_on_ship_bumped', [ship])
		
func _on_ship_bumped(ship):
	assert(ship is Ship)
	
	global.the_match.add_score(ship.get_id(), 1)
	global.arena.show_msg(ship.species, 1, ship.position)
	
