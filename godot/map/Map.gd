extends Control

class_name Map

"""
Map is for selection the games you are going to play
It will get the players from the session, if session exists.
"""

const WIDTH = 200
const HEIGHT = 100
const CELLSIZE = 200

var matrix = []

var selected_sports : Array
export(String, 'map_locked', 'normal', 'win_stage') var state = 'normal' 
export var cursor_scene : PackedScene
onready var camera = $Camera
onready var first_time_camera =$FirstTimeCamera
onready var panels = $CanvasLayerTop/PanelContainer
onready var tween = $Tween
export var focus_path_scene: PackedScene
export var element_in_camera_scene: PackedScene = preload("res://actors/environments/ElementInCamera.tscn")
var num_players : int
var human_players : int = 0
var cpu : int = 0
var max_cpu: int

var hive_shoot_bombs = true setget set_hive_bombs
var diamondsnatch_shoot_bombs = true setget set_diamondsnatch_bombs
var slam_a_gon_shoot_bombs = true setget set_slam_a_gon_bombs

onready var ui = $CanvasLayerTop
onready var cpus = $Content/Controls/CPUs

onready var cursor_tween = $CursorMoveTween

var settings = {} setget set_settings

signal chose_level
signal selection_finished
signal back
signal done

func set_settings(value):
	settings = value
	for key in settings:
		for this_setting in settings[key]:
			var this_setting_value = settings[key][this_setting]
			var setting = get("{key}_{setting}".format({"key": key, "setting": this_setting}))
			$Content/Planets.get_node("{key}_{setting}".format({"key": key, "setting": this_setting})).active = this_setting_value
			
func set_hive_bombs(value: bool):
	hive_shoot_bombs = value
	settings["hive"] = {"shoot_bombs" : hive_shoot_bombs}

func set_diamondsnatch_bombs(value: bool):
	diamondsnatch_shoot_bombs = value
	settings["diamondsnatch"] = {"shoot_bombs" : diamondsnatch_shoot_bombs}
	
func set_slam_a_gon_bombs(value: bool):
	slam_a_gon_shoot_bombs = value
	settings["slam_a_gon"] = {"shoot_bombs" : slam_a_gon_shoot_bombs}

func set_cursors_in_map(players: Dictionary):
	"""
	Given a list of InfoPlayers, it will create cursors for the map
	"""
	num_players = len(players)
	for player_id in players:
		if not players[player_id].cpu:
			human_players += 1
	var i = 0
	for player_id in players:
		var player: InfoPlayer = players[player_id]
		if player.cpu:
			continue
		var cursor = create_cursor(player, i)
		$Content.add_child(cursor)
		
		cursor.connect('try_move', self, '_on_cursor_try_move')
		cursor.connect('select', self, '_on_cursor_select')
		cursor.connect('cancel', self, '_on_cursor_cancel')
		
		var panel = panels.get_node(cursor.player.id)
		panel.species = cursor.species
		panel.enable()
		i += 1
	
func _ready():
	# Check if it is the first time:
	if TheUnlocker.is_map_unlocked():
		first_time_camera.current = false
		camera.enabled = true
		var player = InfoPlayer.new()
		var players = {"p1": player.random_species()}
		if global.session:
			players = global.session.get_players()
		self.set_cursors_in_map(players)
	else:
		first_time_camera.current = true
		camera.enabled = false
		var first_set = $Content/Planets/Set6
		selected_sports = [first_set]
		var central_panel = $CanvasLayerTop/PanelContainer/p1
		central_panel.enable()
		central_panel.map_element = first_set.planet
		
		
			
	
	
	for x in range(WIDTH):
		matrix.append([])
		for _y in range(HEIGHT):
			matrix[x].append(null)
			
	for p in get_tree().get_nodes_in_group('map_point'):
		matrix[int(p.position.x/CELLSIZE)][int(p.position.y/CELLSIZE)] = p
		
	
	# TODO: NAMING CONVENTION in group with SPORT
	for sport in get_tree().get_nodes_in_group("sports"):
		var levels = sport.planet.get_levels(num_players)
		var set = sport.planet
		
		if not levels:
			sport.not_available = true
			
		if sport.planet in selected_sports:
			sport.active = true
		sport.status = "locked"
		if TheUnlocker.unlocked_sets.get(set.id, false):
			sport.status = "unlocked"
	
	
	for cell in get_tree().get_nodes_in_group('mapcell'):
		cell.connect('pressed', self, '_on_cell_pressed', [cell])
	
	max_cpu = global.MAX_PLAYERS - human_players
	
	cpus.initialize(int(human_players==1), max_cpu+1)
	self.create_graph()
	

func create_cursor(player: InfoPlayer, index: int = 0) -> MapCursor:
	
	var cursor: MapCursor = cursor_scene.instance()
	cursor.species = player.species
	cursor.player = player
	cursor.cell_size = CELLSIZE
	cursor.grid_position = Vector2(0, 0)
	cursor.z_index = 100 - index
	cursor.rotation_degrees = 60*(index-human_players/2.0 + 0.5)
	cursor.wait = 0.25*index
	return cursor
	
func _on_cursor_try_move(cursor, direction):
	var desired_position = cursor.grid_position
	
	var prev_cell = get_cell(CELLSIZE * desired_position)
	
	if direction == 'N':
		desired_position.y -= 1
	elif direction == 'S':
		desired_position.y += 1
	elif direction == 'W':
		desired_position.x -= 1
	elif direction == 'E':
		desired_position.x += 1
		
	var cell = get_cell(CELLSIZE * desired_position)
	
	if not cell:
		return
	var panel = panels.get_node(cursor.player.id)
	panel.map_element = null
	if cell.is_in_group("sports"):
		panel.map_element = cell.planet
	if cell is OptionCell:
		panel.map_element = cell
		
	cursor.set_grid_position(desired_position)
	
func _on_cursor_select(cursor):
	var cell = get_cell(CELLSIZE * cursor.grid_position)
	
	if not cell:
		return
	
	cell.act(cursor)
	
func _on_cursor_cancel(cursor):
	var cell = get_cell(CELLSIZE * cursor.grid_position)
	if not cell:
		return
	cell.deactivate(cursor)
	cursor.enable()
	var panel = panels.get_node(cursor.player.id)
	panel.map_element = null
	panel.chosen = false
	var i = selected_sports.find(cell)
	if i >= 0:
		selected_sports.remove(i)
		players_ready -= 1
	
func get_cell(position):
	return matrix[int(position.x/CELLSIZE)][int(position.y/CELLSIZE)]

func get_selection():
	var ret = []
	for set in selected_sports:
		assert(set is MapPlanet)
		ret.append(set.planet)
	return ret
	
func _on_cell_pressed(cursor, cell):
	# update data
	
	if cell.is_in_group("sports"):
		var panel = panels.get_node(cursor.player.id)
		panel.map_element = cell.planet
		panel.chosen = true
		if not cell in selected_sports:
			selected_sports.append(cell)
		players_ready += 1
		
		_on_Start_pressed(cursor)
	
var players_ready = 0

func _on_Start_pressed(cursor):
	if len(selected_sports) <= 0:
		return
	cursor.disable()
	for cursor in get_tree().get_nodes_in_group('map_cursor'):
		if cursor.enabled:
			return
	for cursor in get_tree().get_nodes_in_group('map_cursor'):
		cursor.set_unresponsive()
	var playing = ""
	var sets: Array = []
	for sport in selected_sports:
		sets.append(sport.planet)
		playing += " "+ str(sport.planet.id)
		# Can we unlock?
		var locked_games = sport.planet.locked_games()
	print(playing)
	yield(get_tree().create_timer(1), "timeout")
	emit_signal('done', {"sets": sets})
		
func _on_Back_pressed(cursor):
	emit_signal("back")
	
func _unhandled_input(event):
	if event.is_action_pressed("pause") and not global.demo:
		
		emit_signal("back")

var screen_width = ProjectSettings.get_setting('display/window/size/width')
var screen_height = ProjectSettings.get_setting('display/window/size/height')

func choose_level(level):
	# This will choose randonly one minigame. And animate afterwards
	var this_gamemode = level.game_mode
	var back_pos = Vector2(0,0)
	var back_scale = Vector2(1,1)
	var chosen_minicard
	# animation pseudo random for choosing minicard
	var minicards = get_tree().get_nodes_in_group("minicard")
	
	var index_selection = 0
	var index = 0
	
	# TODO: This needs better refactoring.
	for minicard in get_tree().get_nodes_in_group("minicard"):
		if minicard.content.get_id() == this_gamemode.get_id():
			index_selection = index
			back_pos = minicard.position
			back_scale = minicard.scale
			chosen_minicard = minicard
			minicard.z_index = 1000
			tween.interpolate_property(minicard, "global_position", minicard.global_position, Vector2(screen_width,screen_height)/2, 1.5, Tween.TRANS_QUINT, Tween.EASE_IN_OUT)
			tween.interpolate_property(minicard, "scale", minicard.scale, Vector2(3,3), 1.5, Tween.TRANS_QUINT, Tween.EASE_IN_OUT)
			break
		index+=1
	
	
	random_selection(minicards, index_selection)
	yield(self, "selection_finished")
	minicards[index_selection].selected = true
	var wait_time = 0.3
	print("wait time: "+str(wait_time))
	yield(get_tree().create_timer(wait_time), "timeout")
	minicards[index_selection].selected = false
	if chosen_minicard.status == "locked":
		chosen_minicard.unlock()
		yield(chosen_minicard, "unlocked")
		
		# unlock and SAVE
		TheUnlocker.unlock_game(this_gamemode.id)
		persistance.save_game()
	
	tween.start()
	yield(tween, "tween_all_completed")
	chosen_minicard.position = back_pos
	chosen_minicard.scale = back_scale
	chosen_minicard.z_index = 0
	emit_signal("chose_level")

func random_selection(list, sel_index):
	var index = 0
	var wait_time = min(0.1 + float("0."+str(index)), 0.3)
	for i in range(2):
		wait_time = min(0.1 + float("0."+str(index)), 0.3)
		print("wait time: "+str(wait_time))
		for elem in list:
			elem.selected = true
			yield(get_tree().create_timer(wait_time), "timeout")
			elem.selected = false
		index += 1
	# one last time
	wait_time = min(0.1 + float("0."+str(index)), 0.3)
	print("wait time: "+str(wait_time))
	for i in range(sel_index):
		list[i].selected = true
		yield(get_tree().create_timer(wait_time), "timeout")
		list[i].selected = false
	emit_signal("selection_finished")

func _input(event):
	if event.is_action_pressed("debug"):
		Engine.time_scale -= 0.2
	if event.is_action_pressed("continue"):
		Engine.time_scale += 0.2
		
func unlock_via_path(object_to_unlock: MapLocation, object_from: MapLocation) -> void:
	
	# let's grab the path that connect the two objects
	var path_to_traverse = null
	for path in get_tree().get_nodes_in_group("map_paths"):
		assert(path is MapPath)
		if path.to == object_to_unlock and path.from == object_from:
			path_to_traverse = path
			break
	assert(path_to_traverse) # Path between the two NOT FOUND
	path_to_traverse.unlock()
	var center_camera = global.calculate_center(camera.camera_rect)
	# remove cursors from camera, if any
	var cursors = []
	for cameraman in get_tree().get_nodes_in_group("map_cursor"):
		cursors.append(cameraman)
		cameraman.remove_from_group("in_camera")
		
	var element_in_camera = element_in_camera_scene.instance()
	element_in_camera.position = center_camera
	var start_path = path_to_traverse.points[0]
	
	add_child(element_in_camera)
	element_in_camera.move(start_path, 2)
	var focus = focus_path_scene.instance()
	yield(element_in_camera, "completed")
	
	add_child(focus)
	yield(get_tree(), "idle_frame")
	focus.set_points(path_to_traverse.points)
	focus.add_point(object_to_unlock.position)
	
	focus.animate()
	element_in_camera.deactivate()
	yield(focus, "completed")
	
	# Animation for unlocking SET
	object_to_unlock.unlock()
	yield(object_to_unlock, "unlocked")
	
	element_in_camera.position = object_to_unlock.position
	
	# come back where the center was
	element_in_camera.move(center_camera, 2)
	
	# Let's clear everything
	focus.clear()
	focus.queue_free()
	yield(element_in_camera, "completed")
	element_in_camera.queue_free()
	
	
	for elem in cursors:
		elem.add_to_group("in_camera")
	
	
	
var graph = Graph.new()

func create_graph():
	for path in get_tree().get_nodes_in_group("map_paths"):
		var loc : MapLocation = path.from
		var to = path.to
		loc.add_path(path)
		graph.add_path(path)
	print(graph)

func unlock_mode():
	"""
	This will find if and what to unlock and will make the animation or give input accordingly
	"""
	var winner: InfoPlayer = global.session.get_winner()
	var cursor: MapCursor = create_cursor(winner)
	$Content.add_child(cursor)
	if not TheUnlocker.first_check():
		first_time_camera.current = false
		camera.enabled = true
