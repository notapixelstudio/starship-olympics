extends Control

const WIDTH = 200
const HEIGHT = 100
const CELLSIZE = 200
var matrix = []
var back = false

var current_planets = []
export var playlist_item : PackedScene
export var cursor_scene : PackedScene
onready var camera = $Camera

var num_players : int
onready var playlist = $CanvasLayerTop/HUD/Items
onready var intro = $CanvasLayerTop/HUD/Intro
onready var button = $CanvasLayerTop/HUD/Button

onready var cursor_tween = $CursorMoveTween

func _ready():
	back = false
	current_planets = []
	
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
		cursor.connect('proceed', self, 'on_cursor_proceed')
	
	for planet in get_tree().get_nodes_in_group("planets"):
		var levels = (planet as MapPlanet).planet.get("levels_"+str(num_players)+"players")
		if not levels:
			planet.not_available = true
	
	intro.text = intro.text.replace("X", str(num_players))

func initialize(players):
	var human_players : float = 0
	for player_id in players:
		if not players[player_id].cpu:
			human_players += 1
	
	var i = 0
	for player_id in players:
		var player = players[player_id]
		
		if player.cpu:
			continue
			
		var cursor = cursor_scene.instance()
		cursor.species = (player as InfoPlayer).species_template
		cursor.player = (player as InfoPlayer)
		cursor.player_i = i
		cursor.cell_size = CELLSIZE
		cursor.grid_position = Vector2(0, 0)
		cursor.z_index = 100 - i
		cursor.rotation_degrees = 60*(i-human_players/2 + 0.5)
		cursor.wait = 0.25*i
		$Content.add_child(cursor)
		i += 1
	
	num_players = len(players)
	
	
func _on_cursor_try_move(cursor, direction):
	var desired_position = cursor.grid_position
	
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
		
	cursor.set_grid_position(desired_position)
	
func _on_cursor_select(cursor):
	var cell = get_cell(CELLSIZE * cursor.grid_position)
	
	if not cell or not (cell is MapPlanet):
		return
	
	if cell is MapPlanet and (cell as MapPlanet).not_available:
		return
		
	# if we want to give just ONE choice we would disable
	#cursor.disable()
	
	#var item = playlist_item.instance()
	#item.species = cursor.species 
	#item.planet = cell.planet
	#item.name = cursor.name
	#playlist.add_child(item)
	
	cell.toggle_active()
	
func _on_cursor_cancel(cursor):
	pass
	# TODO: get the item in a better way
	#var item = playlist.get_node(cursor.name)
	
	#if not item:
	#	back = true
	#	emit_signal('done')
	#	return
	
	#item.queue_free()
	#cursor.enable()
	
func get_cell(position):
	return matrix[int(position.x/CELLSIZE)][int(position.y/CELLSIZE)]

func timeout_chosen():
	for item in playlist.get_children():
		current_planets.append(item.planet)
	emit_signal('done')

signal done
func on_cursor_proceed(cursor):
	for item in playlist.get_children():
		current_planets.append(item.planet)
	emit_signal('done')

func _process(delta):
	$CanvasLayerTop/HUD/GameStart/Tot.text = str(int($CanvasLayerTop/Timer.time_left))

func _on_Timer_timeout():
	for item in playlist.get_children():
		current_planets.append(item.planet)
	emit_signal('done')
