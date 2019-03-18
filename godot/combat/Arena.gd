"""
Arena Node that will handle all the combat logic
"""
extends Node

var width
var height
var someone_died = 0

export (PackedScene) var gameover_scene
export (float) var size_multiplier = 2.0

var mouse_target  = Vector2(1600, 970)
var debug = false
# analytics
var run_time = 0

onready var DebugNode = $Debug/DebugNode
onready var Battlefield = $Battlefield
onready var SpawnPlayers = $SpawnPositions/Players
onready var camera = $Camera
onready var canvas = $CanvasLayer
onready var hud = $CanvasLayer/HUD
onready var getready = $CanvasLayer/GetReady
onready var pause = $CanvasLayer/Pause

signal screensize_changed(screensize)
signal gameover
signal restart
signal back_to_menu

var array_players = [] # Dictionary of InfoPlayers
var mockup = false
var game_mode

func from_spawner_to_infoplayer(current_player : PlayerSpawner) -> InfoPlayer:
	var info_player = InfoPlayer.new()
	info_player.id = current_player.name
	info_player.controls = current_player.controls
	info_player.species = current_player.species_template.species_name
	info_player.species_template = current_player.species_template
	info_player.cpu = current_player.cpu
	return info_player

func from_info_to_spawner(player_info):
	var spawner = PlayerSpawner.new()
	spawner.controls = player_info.controls 
	spawner.species_template = player_info.species_template
	spawner.name = player_info.id
	spawner.info_player = player_info
	return spawner

func initialize(players:Dictionary) -> void:
	array_players = []
	for p in players:
		array_players.append(players[p])
	
func compute_arena_size():
	"""
	compute the battlefield size
	"""
	width = OS.window_size.x * size_multiplier
	height = OS.window_size.y * size_multiplier
	emit_signal("screensize_changed", Vector2(width, height))
	return Vector2(width, height)

func _ready():
	if not mockup:
		Soundtrack.play("Fight", true)
	else:
		hud.visible = false
	compute_arena_size()
	camera.zoom *= size_multiplier
	
	# Engine.time_scale = 0.2
	# in order to get the size
	get_tree().get_root().connect("size_changed", self, "compute_arena_size")
	run_time = OS.get_ticks_msec()
	
	# get number of players
	# n_players = get_num_players()
	
	# Analytics
	analytics.start_elapsed_time()
	
	# setup Bomb spawners
	
	# set the game mode
	game_mode = CrownMode.new()
	game_mode.connect("game_over", self, "on_gamemode_gameover")

	# set up the spawners
	var i = 0
	for s in $SpawnPositions/Players.get_children():
		if len(array_players) >= i+1:
			s.controls = array_players[i].controls
			s.species_template = array_players[i].species_template
		else:
			array_players.append(from_spawner_to_infoplayer(s))
		i += 1
	print(array_players)
	spawn_ships(array_players)
	for info in array_players:
		print(info.to_dict())
	game_mode.initialize(array_players)
	
	# initialize HUD
	hud.initialize(game_mode)
	
	camera.initialize(compute_arena_size(), size_multiplier)
	
	
	get_tree().paused = true
	if not mockup:
		getready.start()
		yield(getready, "finished")
		get_tree().paused = false
	
	
func _process(delta):	
	game_mode.update(delta)

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		pause.start()
	var debug_pressed = event.is_action_pressed("debug")
	if debug_pressed:
		debug = not debug
		OS.window_fullscreen = !OS.window_fullscreen
		# DebugNode.visible = debug
		
	# reset by command only through debug
	if event.is_action_pressed('continue') and debug:
		reset(global.level)
	
func reset(level):
	someone_died = false
	get_tree().change_scene_to(load("res://screens/game_screen/levels/"+level))

func get_num_players()->int:
	"""
	Depending on the arena we are in.
	Works after ready
	"""
	return SpawnPlayers.get_child_count()

func _on_background_item_rect_changed():
	print("Windows changed")

func hud_update(player_id : String, score:int, collectable_owner:String = ""):
	hud._on_Arena_update_score(player_id, score, collectable_owner)

func ship_just_died(ship: Ship):
	"""
	remove from it, and reput it after a bit
	"""
	Battlefield.call_deferred("remove_child", ship)
	
	yield(get_tree().create_timer(3), "timeout")
	
	if game_mode.game_over:
		return
	
	# respawn
	Battlefield.call_deferred("add_child", ship)
	
func on_gamemode_gameover(winner:String, scores: Dictionary):
	var game_over = gameover_scene.instance()
	canvas.add_child(game_over)
	game_over.raise()
	game_over.initialize(winner, scores)
	
func spawn_ships(spawners):
	for player in SpawnPlayers.get_children():
		spawn_ship(player)
	
onready var combat_manager = $CombatManager
onready var stun_manager = $StunManager
onready var collect_manager = $CollectManager
onready var environments_manager = $EnvironmentsManager

const ship_scene = preload("res://actors/battlers/Ship.tscn")
const cpu_ship_scene = preload("res://actors/battlers/CPUShip.tscn")

func spawn_ship(player:PlayerSpawner):
	var ship 
	if player.is_cpu():
		ship = cpu_ship_scene.instance()
	else:
		ship = ship_scene.instance()
		
	ship.arena = self
	ship.controls = player.controls
	ship.species_template = player.species_template
	ship.position = player.position
	ship.rotation = player.rotation
	ship.height = height
	ship.width = width
	ship.name = player.name
	
	Battlefield.add_child(ship)
	
	# connect signals
	ship.connect("dead", self, "ship_just_died")
	ship.connect("near_area_entered", combat_manager, "ship_near_area_entered")
	ship.connect("near_area_entered", collect_manager, "ship_near_area_entered")
	ship.connect("near_area_entered", environments_manager, "_on_sth_entered")
	ship.connect("near_area_exited", environments_manager, "_on_sth_exited")
	ship.connect("detection", combat_manager, "ship_within_detection_distance")
	ship.connect("body_entered", stun_manager, "ship_collided", [ship])
	ship.connect("crown_dropped", self, "_on_crown_dropped")
	
	return ship
	
const bomb_scene = preload('res://actors/weapons/Bomb.tscn')
func spawn_bomb(pos, impulse, ship):
	var bomb = bomb_scene.instance()
	bomb.initialize(pos, impulse, ship)
	
	bomb.connect("near_area_entered", combat_manager, "bomb_near_area_entered")
	bomb.connect("near_area_entered", environments_manager, "_on_sth_entered")
	bomb.connect("near_area_exited", environments_manager, "_on_sth_exited")
	
	Battlefield.add_child(bomb)
	
	return bomb
	
const crown_scene = preload("res://combat/collectables/Crown.tscn")
func spawn_crown(pos, linear_velocity):
	var crown = crown_scene.instance()
	crown.linear_velocity = linear_velocity
	crown.position = pos
	Battlefield.add_child(crown)
	
func _on_crown_dropped(ship):
	game_mode.crown_lost()
	spawn_crown(ship.position, ship.linear_velocity)
	

func _on_Pause_back_to_menu():
	emit_signal("back_to_menu")


func _on_Pause_restart():
	print("restarto combat")
	emit_signal("restart")
