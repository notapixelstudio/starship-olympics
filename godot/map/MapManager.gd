extends Node

export var panels_path : NodePath
export var BallScene : PackedScene

var panels: MapPanelContainer

var selected_planets = []
var players_ready = {}
var ready = false

var graph := Graph.new()

func _ready():
	# setup player panels
	panels = get_node(panels_path)
	var players = global.the_game.get_players()
	for player in players:
		var panel = panels.get_node(player.id)
		panel.set_player(player)
		panel.enable()
		
	Events.connect("sth_tapped", self, '_on_sth_tapped')
	
	Events.connect('continue_after_game_over', self, '_on_continue_after_game_over')
	
	global.arena.connect("all_ships_spawned", self, '_on_all_ships_spawned')
	
	# wait for the entire Arena subtree to be ready
	yield(get_tree(), "idle_frame")
	
	# connect MapLocations in a graph
	var nodes = traits.get_all_with('Node')
	for link in traits.get_all_with('Link'):
		var endpoints = link.get_global_endpoints()
		var start: MapLocation = null
		var end: MapLocation = null
		
		for node in nodes:
			var polygon = node.get_global_polygon()
			if Geometry.is_point_in_polygon(endpoints.start, polygon):
				start = node
				continue # no self-links
			
			if Geometry.is_point_in_polygon(endpoints.end, polygon):
				end = node
				continue # no self-links
			
		if start != null and end != null:
			graph.add_path(link, start, end)
			
	print(graph.to_string())
	
func _on_all_ships_spawned(spawners):
	# give a star to the winner of the former session
	var winner = global.the_game.get_last_winner()
	if winner != null:
		var winner_ship = global.arena.get_ship_from_player(winner)
		var star = BallScene.instance()
		star.set_type('star')
		add_child(star) # has to be inside the tree to be loaded
		winner_ship.get_cargo().load_holdable(star)
		
		# also unhide new unlockable content
		var nodes = traits.get_all_with('Node')
		for node in nodes:
			if node.get_status() == 'unlocked':
				self.explore(node)
		
func _on_sth_tapped(tapper : Ship, tappee : MapPlanet):
	if tapper is Ship and tappee is MapPlanet:
		tap(tapper, tappee)
	
func tap(ship : Ship, planet : MapPlanet):
	assert(ship is Ship)
	assert(planet is MapPlanet)
	
	if planet.get_status() == TheUnlocker.UNLOCKED:
		
		if ship.get_id() in players_ready:
			return
		
		var panel = panels.get_node(ship.get_id())
		panel.set_content(planet.get_set())
		panel.set_chosen(true)
		players_ready[ship.get_id()] = planet.get_set()
		check_all_ready()

	elif planet.get_status() == TheUnlocker.LOCKED and ship.get_cargo().has_holdable():
		var cargo = ship.get_cargo()
		if cargo.get_holdable().has_type('star'):
			planet.unlock()
			cargo.empty()

func check_all_ready():
	if not ready and len(players_ready) == global.the_game.get_number_of_players():
		ready = true
		global.new_session()
		setup_session()
		pick_next_minigame()
		
func setup_session():
	var players = global.the_game.get_players()
	var players_selection := {} # player_id -> Set
	for player in players:
		var panel: MapPanel = panels.get_node(player.id)
		players_selection[player.id] = panel.content
	print(players_selection)
	global.session.setup_players_selection(players_selection)

func pick_next_minigame():
	var player_and_minigame = global.session.choose_next_level()
	yield(get_tree().create_timer(1), "timeout")
	panels.choose_level(player_and_minigame["player"], player_and_minigame["level"])
	
func _on_continue_after_game_over(session_ended):
	if not session_ended:
		pick_next_minigame()

## WARNING if the game is killed halfway through, an inconsisent state could be persisted
func explore(node) -> void:
	var neighbourhood := graph.get_neighbourhood(node)
	for n in neighbourhood.keys(): # MapLocations
		var path = neighbourhood[n]
		if TheUnlocker.get_status("map_paths", path.name, TheUnlocker.HIDDEN) == TheUnlocker.HIDDEN:
			path.appear()
			TheUnlocker.unlock_element("map_paths", path.name)
		yield(path, 'appeared')
		if n is MapPlanet:
			n.unhide()
			yield(n, 'unhid')
			TheUnlocker.unlock_element("sets", n.get_id(), TheUnlocker.LOCKED)
		elif n is Waypoint:
			n.unlock()
			
