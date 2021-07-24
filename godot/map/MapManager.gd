extends Node

export var panels_path : NodePath
export var foreground_path: NodePath
export var content_path: NodePath
export var cursor_scene: PackedScene

var panels: MapPanelContainer

var selected_planets = []
var players_ready = {}
var ready = false

func _ready():
	panels = get_node(panels_path)
	var players = global.session.get_players()
	for id in players.keys():
		var panel = panels.get_node(id)
		panel.set_player(players[id])
		panel.enable()
		
	Events.connect("sth_tapped", self, '_on_sth_tapped')
	Events.connect("match_ended", self, '_on_match_ended')
	
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
		#if not planet in selected_planets:
		#	selected_planets.append(planet)
		#players_selection[cursor.player.id] = cell.planet
		players_ready[ship.get_id()] = planet.get_set().get_id()
		check_all_ready()
		var cursor: MapCursor = cursor_scene.instance()
		cursor.setup(ship.info_player)
		cursor.position = planet.position
		get_node(content_path).add_child(cursor)
		get_node(foreground_path).remove_child(ship)
		#_on_Start_pressed(cursor)
	#elif cell.get_status() == TheUnlocker.LOCKED and cursor.is_winner():
	#	TheUnlocker.unlock_set(cell.get_id())
	#	cell.set_status(TheUnlocker.get_status_set(cell.get_id()))
	#	cursor.spend_winnership()

func check_all_ready():
	if not ready and len(players_ready) == global.session.get_number_of_players():
		ready = true
		pick_next_minigame()
		
func pick_next_minigame():
	var players = global.session.get_players()
	var players_selection = {}
	for id in players.keys():
		var panel: MapPanel = panels.get_node(id)
		players_selection[id] = panel.content
	print(players_selection)
	global.session.setup_players_selection(players_selection)
	var player_and_minigame = global.session.choose_next_level()
	yield(get_tree().create_timer(1), "timeout")
	panels.choose_level(player_and_minigame["player"], player_and_minigame["level"])
		
func _on_match_ended():
	pick_next_minigame()
