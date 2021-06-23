extends ModeManager

var active = false

func start():
	active = true

func _process(delta):
	if not enabled or not active:
		return
		
	for ship in get_tree().get_nodes_in_group('players'):
		if ship.alive:
			global.the_match.add_score(ship.get_id(), delta)
