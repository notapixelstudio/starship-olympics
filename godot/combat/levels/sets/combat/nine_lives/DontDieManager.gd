extends Node

func _ready():
	Events.connect('ship_died', Callable(self, '_on_ship_died'))
	
func _on_ship_died(ship, killer, for_good):
	global.the_match.add_score(ship.get_player().id, -1)
	global.arena.show_msg(ship.get_color(), -1, ship.position)
