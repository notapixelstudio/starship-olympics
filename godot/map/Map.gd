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

var num_players : int
var human_players : int = 0
onready var playlist = $CanvasLayerTop/HUD/Items
onready var intro = $CanvasLayerTop/HUD/Intro
onready var button = $CanvasLayerTop/HUD/Button

onready var cursor_tween = $CursorMoveTween

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
	
	for sport in get_tree().get_nodes_in_group("sports"):
		var levels = (sport as MapPlanet).planet.get("levels_"+str(num_players)+"players")
		if not levels:
			sport.not_available = true
			
		if sport.planet in selected_sports:
			sport.active = true
	
	intro.text = intro.text.replace("X", str(num_players))
	
	for cell in get_tree().get_nodes_in_group('mapcell'):
		cell.connect('pressed', self, '_on_cell_pressed', [cell])

func initialize(players, sports):
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
		cursor.species = (player as InfoPlayer).species_template
		cursor.player = (player as InfoPlayer)
		cursor.player_i = i
		cursor.cell_size = CELLSIZE
		cursor.grid_position = Vector2(0, 0)
		cursor.z_index = 100 - i
		cursor.rotation_degrees = 60*(i-human_players/2.0 + 0.5)
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
	
	if not cell:
		return
	
	cell.act(cursor)
	
func _on_cursor_cancel(cursor):
	cursor.enable()
	players_ready -= 1
	
func get_cell(position):
	return matrix[int(position.x/CELLSIZE)][int(position.y/CELLSIZE)]

func _on_cell_pressed(cursor, cell):
	# update data
	selected_sports = []
	for sport in get_tree().get_nodes_in_group('sports'):
		if sport.active:
			selected_sports.append(sport.planet)

signal done
var players_ready = 0
func _on_Start_pressed(cursor):
	if len(selected_sports) <= 0:
		return
		
	cursor.disable()
	players_ready += 1
	if players_ready == human_players:
		for cursor in get_tree().get_nodes_in_group('map_cursor'):
			cursor.set_unresponsive()
			
		yield(get_tree().create_timer(0.5), "timeout")
		emit_signal('done')
		