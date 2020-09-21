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
	
	for sport in get_tree().get_nodes_in_group("sports"):
		var levels = sport.planet.get("levels_"+str(num_players)+"players")
		if not levels:
			sport.not_available = true
			
		if sport.planet in selected_sports:
			sport.active = true
	
	
	for cell in get_tree().get_nodes_in_group('mapcell'):
		cell.connect('pressed', self, '_on_cell_pressed', [cell])
	
	max_cpu = global.MAX_PLAYERS - human_players
	
	cpus.initialize(int(human_players==1), max_cpu+1)

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
	panel.planet = null
	if cell.is_in_group("sports"):
		panel.planet = cell.planet
		
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
	panel.planet = null
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
		panel.planet = cell.planet
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
	yield(get_tree().create_timer(0.5), "timeout")
	emit_signal('done')
		
func _on_Back_pressed(cursor):
	back = true
	emit_signal("done")
	
func _unhandled_input(event):
	if event.is_action_pressed("pause") and not global.demo:
		back = true
		emit_signal("done")
