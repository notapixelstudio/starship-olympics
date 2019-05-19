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

func _ready():
	back = false
	current_planets = []
	
	for x in range(WIDTH):
		matrix.append([])
		for y in range(HEIGHT):
			matrix[x].append(null)
			
	for p in get_tree().get_nodes_in_group('map_point'):
		matrix[int(p.position.x/CELLSIZE)][int(p.position.y/CELLSIZE)] = p

		
	for c in get_tree().get_nodes_in_group('map_connection'):
		if int(c.rotation_degrees) == 90 or int(c.rotation_degrees) == -90 or int(c.rotation_degrees) == 270 or int(c.rotation_degrees) == -270:
			var south = matrix[int(c.position.x/CELLSIZE)][int((c.position.y+CELLSIZE/2)/CELLSIZE)] as MapPoint
			var north = matrix[int(c.position.x/CELLSIZE)][int((c.position.y-CELLSIZE/2)/CELLSIZE)] as MapPoint
			south.set_neighbour(north, 'N')
			north.set_neighbour(south, 'S')
		elif int(c.rotation_degrees) == 0 or int(c.rotation_degrees) == 180 or int(c.rotation_degrees) == -180 or int(c.rotation_degrees) == 360:
			var east = matrix[int((c.position.x+CELLSIZE/2)/CELLSIZE)][int(c.position.y/CELLSIZE)] as MapPoint
			var west = matrix[int((c.position.x-CELLSIZE/2)/CELLSIZE)][int(c.position.y/CELLSIZE)] as MapPoint
			east.set_neighbour(west, 'W')
			west.set_neighbour(east, 'E')
			
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
	var i = 0
	for player_id in players:
		var player = players[player_id]
		var cursor = cursor_scene.instance()
		cursor.species = (player as InfoPlayer).species_template
		cursor.player_controls = (player as InfoPlayer).controls
		cursor.player_i = i
		cursor.position = Vector2(2*CELLSIZE, CELLSIZE)
		$Content.add_child(cursor)
		i += 1
	
	num_players = len(players)
	
	
func _on_cursor_try_move(cursor, direction):
	var cell = get_cell(cursor)
	
	if not cell:
		return
		
	if not (direction in cell.neighbours):
		return
	if direction == 'N':
		cursor.position.y -= CELLSIZE
	elif direction == 'S':
		cursor.position.y += CELLSIZE
	elif direction == 'W':
		cursor.position.x -= CELLSIZE
	elif direction == 'E':
		cursor.position.x += CELLSIZE
		
func _on_cursor_select(cursor):
	var cell = get_cell(cursor)
	
	if not cell or not (cell is MapPlanet):
		return
	
	if cell is MapPlanet and (cell as MapPlanet).not_available:
		return
		
	# if we want to give just ONE choice we would disable
	# cursor.disable()
	
	var item = playlist_item.instance()
	item.species = cursor.species 
	item.planet = cell.planet
	item.name = cursor.name
	playlist.add_child(item)
	
	
func _on_cursor_cancel(cursor):
	# TODO: get the item in a better way
	var item = playlist.get_node(cursor.name)
	
	if not item:
		back = true
		emit_signal('done')
		return
	
	item.queue_free()
	cursor.enable()
	
		
func get_cell(object):
	return matrix[int(object.position.x/CELLSIZE)][int(object.position.y/CELLSIZE)]

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
	var i = 0
	for planet in get_tree().get_nodes_in_group("planets"):
		planet.info_planet.scale = camera.zoom
		i+=1
	$CanvasLayerTop/HUD/GameStart/Tot.text = str(int($CanvasLayerTop/Timer.time_left))

func _on_Timer_timeout():
	for item in playlist.get_children():
		current_planets.append(item.planet)
	emit_signal('done')
