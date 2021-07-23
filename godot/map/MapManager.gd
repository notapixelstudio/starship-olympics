extends Node

export var panels_path : NodePath
var panels

var selected_planets = []
var players_ready = 0

func _ready():
	panels = get_node(panels_path)
	var players = global.session.get_players()
	for id in players.keys():
		var panel = panels.get_node(id)
		panel.set_player(players[id])
		panel.enable()
		
	Events.connect("sth_tapped", self, '_on_sth_tapped')

func _on_sth_tapped(tapper : Ship, tappee : MapPlanet):
	if tapper is Ship and tappee is MapPlanet:
		tap(tapper, tappee)
	
func tap(ship : Ship, planet : MapPlanet):
	assert(ship is Ship)
	assert(planet is MapPlanet)
	
	if planet.get_status() == TheUnlocker.UNLOCKED:
		var panel = panels.get_node(ship.get_id())
		panel.set_content(planet.get_set())
		panel.set_chosen(true)
		#if not planet in selected_planets:
		#	selected_planets.append(planet)
		#players_selection[cursor.player.id] = cell.planet
		players_ready += 1
		check_all_ready()
		#_on_Start_pressed(cursor)
	#elif cell.get_status() == TheUnlocker.LOCKED and cursor.is_winner():
	#	TheUnlocker.unlock_set(cell.get_id())
	#	cell.set_status(TheUnlocker.get_status_set(cell.get_id()))
	#	cursor.spend_winnership()
func check_all_ready():
	if players_ready == 
	yield(get_tree().create_timer(1), "timeout")
	emit_signal('done', {"sets": sets, "players_selection": players_selection})
