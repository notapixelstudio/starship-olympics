extends Node

func _ready():
	# listen for score updates
	global.the_match.connect('updated',Callable(self,'_on_score_updated'))
	
	# listen for ship entering as a new object
	global.arena.connect('ship_spawned',Callable(self,'_on_ship_spawned'))
	
func _on_ship_spawned(ship):
	update_trail(ship)
	
	ship.connect('collect',Callable(self,'_on_ship_collect').bind(ship))
	ship.connect('dead',Callable(self,'_on_ship_died'))
	ship.connect('spawned',Callable(self,'_on_ship_respawned'))
	
func _on_ship_collect(what, ship):
	if what is Fruit:
		global.the_match.add_score(ship.get_player().id, 1)
		global.arena.show_msg(ship.species, 1, what.global_position)
	
func _on_ship_respawned(ship):
	update_trail(ship)
	
func _on_score_updated(player, broadcasted):
	update_trail(global.arena.get_ship_from_player(player))
	
func _on_ship_died(ship, killer, for_good):
	var malus = min(5, global.the_match.get_score(ship.get_player().id)-1)
	if malus > 0:
		global.the_match.add_score(ship.get_player().id, -malus)
		global.arena.show_msg(ship.species, -malus, ship.position)
		
func update_trail(ship):
	# set trail length to ship score
	var score = global.the_match.get_score(ship.get_player().id)
	ship.trail.set_duration(max(1, score)*0.5)
	
