"""
Arena Node that will handle all the combat logic
"""
extends Node

var width
var height
var someone_died = 0

export (float) var size_multiplier = 2.0

var debug = false
# analytics
var run_time = 0

onready var DebugNode = $Debug/DebugNode
onready var Battlefield = $Battlefield
onready var SpawnPlayers = $SpawnPositions/Players
onready var camera = $Camera

const ship_scene = preload("res://actors/battlers/Ship.tscn")

signal screensize_changed(screensize)

var spawners = []

func initialize(players:Array) -> void:
	spawners = []
	# forcing the array to PlayerSpwawner (as check)
	for player in players:
		assert(player is PlayerSpawner)
	spawners = players
	
func compute_arena_size():
	"""
	compute the battlefield size
	"""
	width = OS.window_size.x * size_multiplier
	height = OS.window_size.y * size_multiplier
	emit_signal("screensize_changed", Vector2(width, height))
	return true

func update_spawner(spawner:PlayerSpawner) -> bool:
	if not spawner:
		return false
	for player in SpawnPlayers.get_children():
		if player.name.to_lower() == spawner.name.to_lower():
			player.controls = spawner.controls
			player.battler_template = spawner.battler_template
			print(player.controls, " ", player.battler_template.species_name)
			return true
	return false
	
func setup_ships():
	if not spawners:
		return
	for player in SpawnPlayers.get_children():
		var ship = ship_scene.instance()
		ship.controls = player.controls
		ship.battle_template = player.battler_template
		ship.position = player.position
		ship.rotation = player.rotation
		ship.height = height
		ship.width = width
		ship.name = player.name
		Battlefield.add_child(ship)
		# connect signals
		ship.connect("dead", self, "update_score", [ship.name])
		connect("screensize_changed", ship, "update_wraparound")
	
func _ready():
	compute_arena_size()
	camera.zoom *= size_multiplier
	# in order to get the size
	get_tree().get_root().connect("size_changed", self, "compute_arena_size")
	run_time = OS.get_ticks_msec()
	
	# get number of players
	# n_players = get_num_players()
	
	# Analytics
	analytics.start_elapsed_time()
	
	# setup Bomb spawners
	for spawner in Battlefield.get_children():
		if spawner.is_in_group("spawner"):
			spawner.spawn()
	
	# set the player spawners
	for spawner in spawners:
		update_spawner(spawner)
	setup_ships()
	
func _unhandled_input(event):
	var debug_pressed = event.is_action_pressed("debug")
	if debug_pressed:
		debug = not debug
		OS.window_fullscreen = !OS.window_fullscreen
		DebugNode.visible = debug
		
	# reset by command only through debug
	if event.is_action_pressed('continue') and debug:
		reset(global.level)
	
func reset(level):
	someone_died = false
	get_tree().change_scene_to(load("res://screens/game_screen/levels/"+level))
	#get_tree().reload_current_scene()

func get_num_players():
	return 4

func _on_background_item_rect_changed():
	print("changed")

func update_score(player_id):
	yield(get_tree().create_timer(1), "timeout")
	for player in SpawnPlayers.get_children():
		if player.name.to_lower() == player_id.to_lower():
			pass