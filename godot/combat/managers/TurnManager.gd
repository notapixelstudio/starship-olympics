extends Node

export var turn_duration_secs := 5
export var skip_cpus := false

var players
var active_player_i := 0

func start():
	players = []
	for player in global.the_game.get_players():
		if not skip_cpus or not player.is_cpu():
			players.append(player)
	
	# we want these to fire only during play, not at the start
	Events.connect("ship_spawned", self, '_on_ship_spawned')
	Events.connect("ship_repaired", self, '_on_ship_repaired')
	
	for ship in get_tree().get_nodes_in_group('Ship'):
		update_ship_state(ship)
		
	$Timer.start(turn_duration_secs)
	
func _exit_tree():
	Events.disconnect("ship_spawned", self, '_on_ship_spawned')
	Events.disconnect("ship_repaired", self, '_on_ship_repaired')
	
func get_active_ship():
	if global.arena.player_has_valid_ship(players[active_player_i]):
		return global.arena.get_ship_from_player(players[active_player_i])
	return null
	
func pass_turn():
	if global.the_match.is_almost_game_over():
		return
		
	var active_ship = get_active_ship()
	if active_ship != null:
		active_ship.time_freeze()
	active_player_i = (active_player_i + 1) % len(players)
	active_ship = get_active_ship()
	if active_ship != null:
		active_ship.time_unfreeze($Timer.time_left)
		
func _on_ship_spawned(ship):
	update_ship_state(ship)
	
func _on_ship_repaired(ship):
	update_ship_state(ship)
	
func update_ship_state(ship):
	if skip_cpus and ship.get_player().is_cpu():
		return
		
	yield(get_tree(), "idle_frame") # we need to wait for ships to settle
	
	if ship == get_active_ship():
		ship.time_unfreeze($Timer.time_left)
	elif not skip_cpus or not ship.get_player().is_cpu():
		ship.time_freeze()

func _on_Timer_timeout():
	pass_turn()
