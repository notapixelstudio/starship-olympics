extends Node

var player_ships = {}

func _ready():
	# listen for score updates
	global.the_match.connect('updated', self, '_on_score_updated')
	
	# listen for ship reentering as new
	global.arena.connect('ship_spawned', self, '_on_ship_spawned') # if we receive this, the ship has spawned as new
	
func register_ship(ship):
	player_ships[ship.get_player().id] = ship
	
	ship.connect('collect', self, '_on_ship_collect', [ship])
	ship.connect('dead', self, '_on_ship_died')
	ship.connect('spawned', self, '_on_ship_spawned') # if we receive this, the ship has REspwaned
	
func unregister_ship(ship):
	player_ships.erase(ship.get_player().id)
	
func _on_ship_collect(what, ship):
	if what is Fruit:
		global.the_match.add_score(ship.get_player().id, 1)
		global.arena.show_msg(ship.species, 1, what.global_position)
	
func _on_ship_spawned(ship):
	register_ship(ship) # this is needed only when a brand new ship is spawned
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
	
	if for_good:
		unregister_ship(ship)
