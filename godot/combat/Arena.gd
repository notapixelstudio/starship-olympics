"""
Arena Node that will handle all the combat logic
"""
extends Node

var width
var height
var someone_died = 0

export (PackedScene) var gameover_scene
export (float) var size_multiplier = 2.0
export var time_scale : float = 1.0 setget set_time_scale, get_time_scale
export var game_mode : Resource # Gamemode - might be useful
export var planet_name : String

var mockup: bool = false
var mouse_target  = Vector2(1600, 970)
var debug = false
# analytics
var run_time = 0

onready var DebugNode = $Debug/DebugNode
onready var SpawnPlayers = $SpawnPositions/Players
onready var camera = $Camera
onready var canvas = $CanvasLayer
onready var hud = $CanvasLayer/HUD
onready var getready = $CanvasLayer/GetReady
onready var pause = $CanvasLayer/Pause
onready var mode_description = $CanvasLayer/DescriptionMode

signal screensize_changed(screensize)
signal gameover
signal restart
signal rematch
signal back_to_menu

var array_players = [] # Dictionary of InfoPlayers


var scores : Scores

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
	return $Battlefield/Background/OutsideWall.extents.get_rect()

func set_time_scale(value):
	time_scale = value
	update_time_scale()
	
func get_time_scale():
	return time_scale
	
func update_time_scale():
	Engine.time_scale = time_scale

signal update_stats

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
	

	scores = Scores.new()
	scores.connect("game_over", self, "on_gamemode_gameover")
	connect("update_stats", scores, "update_stats")
	
	
	$CollectManager.connect('collected', $CrownModeManager, "_on_sth_collected")
	$CollectManager.connect('collected', self, "_on_sth_collected")
	$CollectManager.connect('dropped', $CrownModeManager, "_on_sth_dropped")
	$CollectManager.connect('dropped', self, "_on_sth_dropped")
	$CollectManager.connect("stolen", $CrownModeManager, "_on_sth_stolen")
	$EnvironmentsManager.connect('repel_cargo', $CollectManager, "_on_cargo_repelled")
	$CollectManager.connect('collected', $CollectModeManager, "_on_sth_collected")
	$CollectManager.connect('coins_dropped', $CollectModeManager, "_on_coins_dropped")
	$CollectManager.connect('coins_dropped', self, "_on_coins_dropped")
	$ConquestManager.connect('conquered', $ConquestModeManager, "_on_sth_conquered")
	$ConquestManager.connect('deconquered', $ConquestModeManager, "_on_sth_deconquered")
		
	$CrownModeManager.connect('score', scores, "add_score")
	$DeathmatchModeManager.connect('score', scores, "add_score")
	$RaceModeManager.connect('score', scores, "add_score")
	$ConquestModeManager.connect('score', scores, "add_score")
	$CollectModeManager.connect('score', scores, "add_score")
	
	# set up the spawners
	var i = 0
	for s in $SpawnPositions/Players.get_children():
		var spawner = s as PlayerSpawner
		if len(array_players) >= i+1:
			s.controls = array_players[i].controls
			s.species_template = array_players[i].species_template
			s.cpu = array_players[i].cpu
		else:
			array_players.append(from_spawner_to_infoplayer(s))
		i += 1


	for info in array_players:
		print(info.to_dict())
	scores.initialize(array_players, game_mode.max_timeout)
	
	# initialize HUD
	hud.initialize(scores)
	hud.set_planet(planet_name, game_mode)
	
	camera.initialize(compute_arena_size())

	get_tree().paused = true
	mode_description.gamemode = game_mode
	mode_description.appears()
	yield(mode_description, "ready_to_fight")
	if not mockup:
		getready.start()
		yield(get_tree().create_timer(1), "timeout")
		for s in $SpawnPositions/Players.get_children():
			var spawner = s as PlayerSpawner
			spawner.appears()
			yield(spawner, "entered_battlefield")
			spawn_ship(spawner)
		get_tree().paused = false
		camera.activate_camera()

	else:
		spawn_ships()

	# setup Bomb spawners
	for bomb_spawner in get_tree().get_nodes_in_group("spawner"):
		bomb_spawner.initialize(self)
		if bomb_spawner.owned_by_player and $Battlefield/Foreground.has_node(bomb_spawner.owned_by_player):
			bomb_spawner.owner_ship = $Battlefield/Foreground.get_node(bomb_spawner.owned_by_player)
		bomb_spawner.spawn()
	for turret in get_tree().get_nodes_in_group("turret"):
		turret.initialize(self)
		
	update_time_scale()

func _process(delta):
	scores.update(delta)

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

func ship_just_died(ship: Ship, killer : Ship):
	"""
	remove from it, and reput it after a bit
	"""
	# stats
	# TODO: maybe somewhere else
	emit_signal("update_stats", ship.species, 1, "deaths")
	if killer and killer is Ship and killer != ship:
		emit_signal("update_stats", killer.species, 1, "kills")
	else:
		emit_signal("update_stats", ship.species, 1, "selfkills")
	
	$Battlefield.call_deferred("remove_child", ship)
	$Battlefield.call_deferred("add_child", ship.dead_ship_instance)
	var respawn_timeout = 2
	if len(ECM.entities_with('Royal')) > 0:
		if ECM.E(ship).has('Royal'):
			respawn_timeout = 3
		else:
			respawn_timeout = 1
	
	yield(get_tree().create_timer(respawn_timeout), "timeout")
	
	if scores.game_over:
		return
	
	# respawn
	$Battlefield.call_deferred("remove_child", ship.dead_ship_instance)
	ship.position = ship.dead_ship_instance.position
	$Battlefield.call_deferred("add_child", ship)
	
	
func on_gamemode_gameover(winner:String, scores: Dictionary):
	$GameOver.play('Game Over')
	yield($GameOver, "animation_finished") # wait for animation and UI redraw (esp. bars)
	set_time_scale(1)
	get_tree().paused = true
	var game_over = gameover_scene.instance()
	game_over.connect("rematch", self, "_on_GameOver_rematch")
	game_over.connect("back_to_menu", self, "_on_Pause_back_to_menu")
	canvas.add_child(game_over)
	game_over.initialize(winner, scores)

onready var combat_manager = $CombatManager
onready var stun_manager = $StunManager
onready var collect_manager = $CollectManager
onready var environments_manager = $EnvironmentsManager
onready var crown_mode_manager = $CrownModeManager
onready var deathmatch_mode_manager = $DeathmatchModeManager
onready var conquest_manager = $ConquestManager
onready var pursue_manager = $PursueManager

const ship_scene = preload("res://actors/battlers/Ship.tscn")
const cpu_ship_scene = preload("res://actors/battlers/CPUShip.tscn")
const trail_scene = preload("res://actors/battlers/TrailNode.tscn")

func spawn_ships():
	for player in SpawnPlayers.get_children():
		spawn_ship(player)


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
	
	$Battlefield.add_child(ship)
	
	# create and link trail
	var trail = trail_scene.instance()
	trail.initialize(ship)
	
	$Battlefield.add_child(trail)
	
	# connect signals
	ship.connect("dead", self, "ship_just_died")
	ship.connect("near_area_entered", combat_manager, "_on_ship_collided")
	ship.connect("body_entered", combat_manager, "_on_ship_collided", [ship])
	ship.connect("near_area_entered", collect_manager, "ship_near_area_entered")
	ship.connect("near_area_entered", environments_manager, "_on_sth_entered")
	ship.connect("near_area_exited", environments_manager, "_on_sth_exited")
	ship.connect("detection", pursue_manager, "_on_ship_detected")
	ship.connect("body_entered", stun_manager, "ship_collided", [ship])
	ship.connect("dead", deathmatch_mode_manager, "_on_ship_killed")
	ship.connect("dead", collect_manager, "_on_ship_killed")
	ship.connect("body_entered", conquest_manager, "_on_ship_collided", [ship])
	ship.connect("near_area_entered", conquest_manager, "_on_ship_collided")
	
	return ship
	
const bomb_scene = preload('res://actors/weapons/Bomb.tscn')
func spawn_bomb(pos, impulse, ship):
	var bomb = bomb_scene.instance()
	bomb.initialize(pos, impulse, ship)
	
	bomb.connect("near_area_entered", combat_manager, "bomb_near_area_entered")
	bomb.connect("near_area_entered", environments_manager, "_on_sth_entered")
	bomb.connect("near_area_exited", environments_manager, "_on_sth_exited")
	
	$Battlefield.add_child(bomb)
	
	if ship:
		emit_signal("update_stats", ship.species, 1, "bombs")
	return bomb
	
func _on_sth_collected(collector, collectee):
	$Battlefield.call_deferred('remove_child', collectee) # collisions do not work as expected without defer
	
func _on_sth_dropped(dropper, droppee):
	$Battlefield.add_child(droppee)
	droppee.position = dropper.position
	droppee.linear_velocity = dropper.linear_velocity
	
	# wait a bit, then make the item collectable again
	yield(get_tree().create_timer(0.2), "timeout")
	ECM.E(droppee).get('Collectable').enable()
	
const coin_scene = preload("res://combat/collectables/Coin.tscn")
func _on_coins_dropped(dropper, amount):
	for i in range(amount):
		var coin = coin_scene.instance()
		$Battlefield.add_child(coin)
		coin.position = dropper.position
		coin.linear_velocity = dropper.linear_velocity + Vector2(500,0).rotated(randi()/8/PI)
	
func _on_Pause_back_to_menu():
	emit_signal("back_to_menu")

func _on_GameOver_rematch():
	emit_signal("rematch")

func _on_Pause_restart():
	emit_signal("restart")

func _on_Pause_skip():
	emit_signal("rematch") # WARNING this should be different if we are keeping scores
	
