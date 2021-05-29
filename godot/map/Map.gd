extends Control

class_name Map

const WIDTH = 200
const HEIGHT = 100
const CELLSIZE = 200

var matrix = []

var players_selection : Dictionary = {}
var selected_sports : Array
export var playlist_item : PackedScene
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
	
func _ready():
	# Check if it is the first time:
	if TheUnlocker.is_map_unlocked():
		first_time_camera.current = false
		camera.enabled = true
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
		
	for cursor in get_tree().get_nodes_in_group('map_cursor'):
		cursor.connect('try_move', self, '_on_cursor_try_move')
		cursor.connect('select', self, '_on_cursor_select')
		cursor.connect('cancel', self, '_on_cursor_cancel')
		
		var panel = panels.get_node(cursor.player.id)
		panel.species = cursor.species
		panel.enable()
	
	# TODO: NAMING CONVENTION in group with SPORT
	for sport in get_tree().get_nodes_in_group("sports"):
		# REMOVED check if there are no levels for this number of players
		# var levels = sport.planet.get_levels(num_players)
		var set = sport.planet
		
		#if not levels:
		#	sport.not_available = true
			
		if sport.planet in selected_sports:
			sport.active = true
		sport.status = "locked"
		if TheUnlocker.unlocked_sets.get(set.id, TheUnlocker.UNLOCKED) == TheUnlocker.UNLOCKED:
			sport.status = "unlocked"
	
	
	for cell in get_tree().get_nodes_in_group('mapcell'):
		cell.connect('pressed', self, '_on_cell_pressed', [cell])
	
	max_cpu = global.MAX_PLAYERS - human_players
	
	cpus.initialize(int(human_players==1), max_cpu+1)
	self.create_graph()
	

func initialize(players):
	num_players = len(players)
	for player_id in players:
		if not players[player_id].cpu:
			human_players += 1

	var i = 0
	for player_id in players:
		var player = players[player_id]
		
		if player.cpu:
			continue
			
		var cursor: MapCursor = cursor_scene.instance()
		cursor.species = player.species
		cursor.player = player
		cursor.player_i = i
		cursor.cell_size = CELLSIZE
		cursor.grid_position = Vector2(0, 0)
		cursor.z_index = 100 - i
		cursor.rotation_degrees = 60*(i-human_players/2.0 + 0.5)
		cursor.wait = 0.25*i
		$Content.add_child(cursor)
		# $CanvasLayerTop.get_node(player_id).initialize(player.species)
		i += 1
	
	
	
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
	players_selection.erase(cursor.player.id)
	
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
		players_selection[cursor.player.id] = cell.planet
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
		
	print(playing)
	yield(get_tree().create_timer(1), "timeout")
	emit_signal('done', {"sets": sets, "players_selection": players_selection})
		
func _on_Back_pressed(cursor):
	emit_signal("back")
	
func _unhandled_input(event):
	if event.is_action_pressed("pause") and not global.demo:
		
		emit_signal("back")

var screen_width = ProjectSettings.get_setting('display/window/size/width')
var screen_height = ProjectSettings.get_setting('display/window/size/height')

func choose_level(level, player):
	# This will choose randonly one minigame. And animate afterwards
	var this_gamemode = level.game_mode
	var back_pos = Vector2(0,0)
	var back_scale = Vector2(1,1)
	var chosen_minicard
	
	var index_selection = 0
	var index = 0
	
	# Let's get che chosen minicard, in order to show the transition before the 
	# match starts
	var found = false
	for panel in get_tree().get_nodes_in_group("map_panel"):
		if found:
			break
		for minicard in panel.get_minicards():
			if minicard.content.get_id() == this_gamemode.get_id() and panel.get_player() == player:
				index_selection = index
				back_pos = minicard.position
				back_scale = minicard.scale
				chosen_minicard = minicard
				minicard.z_index = 1000
				tween.interpolate_property(minicard, "global_position", minicard.global_position, Vector2(screen_width,screen_height)/2, 1.5, Tween.TRANS_QUINT, Tween.EASE_IN_OUT)
				tween.interpolate_property(minicard, "scale", minicard.scale, Vector2(3,3), 1.5, Tween.TRANS_QUINT, Tween.EASE_IN_OUT)
				found = true
				break
		index+=1
	
	# animation pseudo random for choosing minicard
	var minicards = get_tree().get_nodes_in_group("minicard")
	random_selection(minicards, index_selection)
	yield(self, "selection_finished")
	chosen_minicard.selected = true
	var wait_time = 0.5
	yield(get_tree().create_timer(wait_time), "timeout")
	chosen_minicard.selected = false
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

func random_selection(list: Array, sel_index, loops=2, max_duration=5):
	list.shuffle()
	list.resize(min(5, len(list)))
	var total_wait: float = 0
	var duration_last_loop = max_duration * 0.8
	var first_loops = max_duration-duration_last_loop
	# each elements will have this speed for the first loops
	var fastest_wait_time = first_loops / len(list) / loops
	print("duration of last loop: " + str(duration_last_loop))
	var num_iterations = len(list)*loops +sel_index
	
	for i in range(num_iterations-1):
		# print("{i}: {what} for {miniga}".format({"i": i, "what": max(fastest_wait_time, duration_last_loop * 1/(pow(2, 1 + num_iterations-i))), "miniga":list[i%len(list)].content.get_id()}))
		var wait_time = max(fastest_wait_time, duration_last_loop * 1/(pow(4, 1 + num_iterations-i)))
		list[i%len(list)].selected = true
		yield(get_tree().create_timer(wait_time), "timeout")
		total_wait+= wait_time
		list[i%len(list)].selected = false
	print("Waited for "+ str(total_wait))
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
	if not TheUnlocker.first_check():
		first_time_camera.current = false
		camera.enabled = true
