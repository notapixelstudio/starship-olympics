extends Node

var player_ships = {}

func start():
	# register all ships
	for ship in get_tree().get_nodes_in_group('player_ship'):
		player_ships[ship.get_player().id] = ship
		
		ship.connect('spawned', self, '_on_ship_spawned')
		ship.connect('dead', self, '_on_ship_died')
		
	# listen for score updates
	global.the_match.connect('updated', self, '_on_score_updated')
	
func _on_ship_spawned(ship):
	update_trail(ship)
	
func _on_score_updated(player, broadcasted):
	# FIXME this crashes because we lose a ship ref if it dies outside
	update_trail(player_ships[player.id])
	
func update_trail(ship):
	# set trail length to ship score
	var score = global.the_match.get_score(ship.get_player().id)
	ship.trail.set_duration(max(1, score)*0.5)
	
func _on_ship_died(ship, killer, for_good):
	var malus = min(5, global.the_match.get_score(ship.get_player().id)-1)
	if malus > 0:
		global.the_match.add_score(ship.get_player().id, -malus)
		global.arena.show_msg(ship.species, -malus, ship.position)
	
