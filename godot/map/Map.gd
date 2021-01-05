extends Control

const WIDTH = 200
const HEIGHT = 100
const CELLSIZE = 200

var matrix = []
var back = false

var selected_sports : Array
export var playlist_item : PackedScene
export var cursor_scene : PackedScene
onready var camera = $Camera
onready var panels = $CanvasLayerTop/PanelContainer
onready var tween = $Tween
export var focus_path_scene: PackedScene = preload("res://map/PathMap.tscn")
export var element_in_camera_scene: PackedScene = preload("res://actors/environments/ElementInCamera.tscn")
var num_players : int
var human_players : int = 0
var cpu : int = 0
var max_cpu

var hive_shoot_bombs = true setget set_hive_bombs
var diamondsnatch_shoot_bombs = true setget set_diamondsnatch_bombs
var slam_a_gon_shoot_bombs = true setget set_slam_a_gon_bombs

onready var ui = $CanvasLayerTop
onready var cpus = $Content/Controls/CPUs

onready var cursor_tween = $CursorMoveTween

var settings = {} setget set_settings

signal chose_level
signal selection_finished
signal unlock_complete
signal check_completed

func check():
	var set = $Content/Planets/Set6.planet
	var locked = 0
	
	for minigame in set.minigames:
		if not TheUnlocker.unlocked_games.get(minigame.id, false):
			locked+=1
	if locked <= 0:
		# WE WILL UNLOCK!
		unlock_via_path($Content/Planets/Set3, $Content/Planets/Set6)
		TheUnlocker.unlock_set($Content/Planets/Set3.planet.id)
		yield(self, "unlock_complete")
		unlock_via_path($Content/Planets/Set2, $Content/Planets/Set6)
		TheUnlocker.unlock_set($Content/Planets/Set2.planet.id)
		yield(self, "unlock_complete")
	yield(get_tree(), "idle_frame")
	emit_signal("check_completed")

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
	back = false
	
	
	for x in range(WIDTH):
		matrix.append([])
		for y in range(HEIGHT):
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
	
	# TODO: NAMING CONVENTION
	for sport in get_tree().get_nodes_in_group("sports"):
		var levels = sport.planet.get("levels_"+str(num_players)+"players")
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
	
	# unlock_via_path($Content/Planets/Set2, $Content/Planets/Set3)

func initialize(players, sports, settings_):
	self.settings = settings_
	selected_sports = sports
	
	for player_id in players:
		if not players[player_id].cpu:
			human_players += 1

	var i = 0
	for player_id in players:
		var player = players[player_id]
		
		if player.cpu:
			continue
			
		var cursor = cursor_scene.instance()
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
	
	num_players = len(players)
	
	
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
	var i = selected_sports.find(cell.planet)
	if i >= 0:
		selected_sports.remove(i)
		players_ready -= 1
		print("players ready "+ str(players_ready))
	
func get_cell(position):
	return matrix[int(position.x/CELLSIZE)][int(position.y/CELLSIZE)]

func _on_cell_pressed(cursor, cell):
	# update data
	if cell.is_in_group("sports"):
		var panel = panels.get_node(cursor.player.id)
		panel.map_element = cell.planet
		panel.chosen = true
		if not cell.planet in selected_sports:
			selected_sports.append(cell.planet)
		players_ready += 1
		
		_on_Start_pressed(cursor)
	
signal done
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
	for sport in selected_sports:
		playing += " "+ str(sport.name)
	print("playing: "+ playing)
	yield(get_tree().create_timer(1), "timeout")
	emit_signal('done')
		
func _on_Back_pressed(cursor):
	back = true
	emit_signal("done")
	
func _unhandled_input(event):
	if event.is_action_pressed("pause") and not global.demo:
		back = true
		emit_signal("done")

var screen_width = ProjectSettings.get_setting('display/window/size/width')
var screen_height = ProjectSettings.get_setting('display/window/size/height')

func choose_level(level):
	var this_gamemode = level.game_mode
	var back_pos = Vector2(0,0)
	var back_scale = Vector2(1,1)
	var chosen_minicard
	# animation pseudo random for choosing minicard
	var minicards = get_tree().get_nodes_in_group("minicard")
	
	var index_selection = 0
	var index = 0
	
	for minicard in get_tree().get_nodes_in_group("minicard"):
		
		if minicard.content == this_gamemode:
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
		
func unlock_via_path(object_to_unlock, object_from):
	
	# let's grab the path that connect the two objects
	var path_to_traverse = null
	for path in get_tree().get_nodes_in_group("map_paths"):
		assert(path is MapPath)
		if path.to == object_to_unlock and path.from == object_from:
			path_to_traverse = path
			break
	assert(path_to_traverse) # Path between the two NOT FOUND
	var center_camera = global.calculate_center(camera.camera_rect)
	# remove from camera
	var backs = []
	for cameraman in get_tree().get_nodes_in_group("in_camera"):
		backs.append(cameraman)
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
	focus.clear()
	focus.queue_free()
	yield(element_in_camera, "completed")
	
	for b in backs:
		b.add_to_group("in_camera")
	
	emit_signal("unlock_complete")
	
	
	
