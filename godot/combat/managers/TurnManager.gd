extends Node

var ships := []
var active_ship_i := 0

func _ready():
	Events.connect("sth_countdown_expired", self, '_on_sth_countdown_expired')
	
func start():
	ships = get_tree().get_nodes_in_group('Ship')
	var i := 0
	for ship in ships:
		if i == active_ship_i:
			ship.time_unfreeze()
		else:
			ship.time_freeze()
		i += 1
		
func pass_turn():
	ships[active_ship_i].time_freeze()
	active_ship_i = (active_ship_i + 1) % len(ships)
	ships[active_ship_i].time_unfreeze()

func _on_sth_countdown_expired(sth):
	if sth is Ship:
		pass_turn()
		
