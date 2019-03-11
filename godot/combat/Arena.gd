"""
Arena Node that will handle all the combat logic
"""
extends Node

var width
var height
var someone_died = 0

export (float) var size_multiplier = 2.0

var mouse_target  = Vector2(1600, 970)
var debug = false
# analytics
var run_time = 0

onready var DebugNode = $Debug/DebugNode
onready var Battlefield = $Battlefield
onready var SpawnPlayers = $SpawnPositions/Players
onready var camera = $Camera
onready var hud = $Pause/HUD
onready var getready = $Pause/GetReady
onready var pause = $Pause/Pause

# Crown might be null, if someone has it or ... if the mode is not crownmode

signal screensize_changed(screensize)
signal gameover
signal rematch

var spawners = []
var mockup = false
var game_mode

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
	return Vector2(width, height)

func update_spawner(spawner:PlayerSpawner, index:int) -> bool:
	if not spawner:
		return false
	var player = SpawnPlayers.get_child(index)
	if player:
		player.name = spawner.name
		player.controls = spawner.controls
		player.species_template = spawner.species_template
		return true
	return false
	
func _ready():
	if not mockup:
		Soundtrack.play("Fight", true)
	else:
		$Pause/HUD.visible = false
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
	for spawner in Battlefield.get_children():
		if spawner.is_in_group("spawner"):
			spawner.spawn()
	
	
	# set the player spawners
	var i = 0
	for spawner in spawners:
		update_spawner(spawner, i)
		i+=1
		
	spawn_ships()
	
	# set the game mode
	game_mode = CrownMode.new()
	game_mode.connect("game_over", self, "gameover")
	var player_ids = []
	if not spawners:
		spawners = $SpawnPositions/Players.get_children()
	game_mode.initialize(spawners)
	
	# initialize HUD
	hud.initialize(game_mode)
	
	camera.initialize(compute_arena_size(), size_multiplier)
	
	get_tree().paused = true
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
	#get_tree().reload_current_scene()

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

var ships
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
	
func gameover(winner:String, scores:Dictionary):
	print("gameover")
	emit_signal("gameover", winner, scores)
	
func spawn_ships():
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
	