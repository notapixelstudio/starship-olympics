"""
Arena Node that will handle all the combat logic
"""
extends Node

class_name Arena

var width
var height
var someone_died = 0

export (PackedScene) var gameover_scene
export (bool) var demo = false
export (float) var size_multiplier = 2.0
export var time_scale : float = 1.0 setget set_time_scale, get_time_scale
export var game_mode : Resource # Gamemode - might be useful
export var planet_name : String

export var score_to_win_override : float = 0
export var match_duration_override : float = 0

var mockup: bool = false
var debug = false
# analytics
var run_time = 0

onready var DebugNode = $Debug/DebugNode
onready var SpawnPlayers = $SpawnPositions/Players
onready var camera = $Camera
onready var canvas = $CanvasLayer
onready var hud = $CanvasLayer/HUD
onready var pause = $CanvasLayer/Pause
onready var mode_description = $CanvasLayer/DescriptionMode
onready var grid = $Battlefield/Background/GridPack

var wall_scene = preload('res://actors/environments/Wall.tscn')

signal screensize_changed(screensize)
signal gameover
signal restart
signal rematch
signal back_to_menu

var array_players = [] # Dictionary of InfoPlayers

# TODO: the spawners should be considered by COllectModeManager ?
var diamonds_spawners = []
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

func setup_level(mode : Resource):
	assert(mode is GameMode)
	$CrownModeManager.enabled = mode.crown
	$DeathmatchModeManager.enabled = mode.death
	$CollectModeManager.enabled = mode.collect
	$ConquestModeManager.enabled = mode.hive
	
func _ready():
	# Pick controller label
	$CanvasLayer/DemoLabel.visible = demo

	# Setup goal, Gear and mode managers
	setup_level(game_mode)

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
	
	#$Battlefield/Background/Grid/THEGRIDLINE2.nodeA = $Battlefield/Background/Grid/GridPoint225/RigidBody2D
	#$Battlefield/Background/Grid/THEGRIDLINE2.nodeB = $Battlefield/Background/Grid/GridPoint248/RigidBody2D
	
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
	$ConquestManager.connect('lost', $ConquestModeManager, "_on_sth_lost")
	
	$CrownModeManager.connect('score', scores, "add_score")
	$DeathmatchModeManager.connect('score', scores, "add_score")
	$DeathmatchModeManager.connect('broadcast_score', scores, "broadcast_score")
	$DeathmatchModeManager.connect('show_score', self, "spawn_points_scored")
	$RaceModeManager.connect('score', scores, "add_score")
	$ConquestModeManager.connect('score', scores, "add_score")
	$CollectModeManager.connect('score', scores, "add_score")
	$CollectModeManager.connect('show_score', self, "spawn_points_scored")
	$CollectModeManager.connect('spawn_next', self, "_on_coins_finished")
	
	# environment spawner: coins, etc.
	if get_tree().get_nodes_in_group("spawner_group"):
		focus_in_camera.activate()
		$CollectModeManager.initialize(get_tree().get_nodes_in_group("spawner_group"))

	# set up the spawners
	var i = 0
	for s in $SpawnPositions/Players.get_children():
		var spawner = s as PlayerSpawner
		if len(array_players) >= i+1:
			# todo: fix casdf
			s.controls = array_players[i].controls
			s.species_template = array_players[i].species_template
			s.cpu = array_players[i].cpu
			s.info_player = array_players[i]
		else:
			s.info_player = InfoPlayer.new()
			s.info_player.cpu = s.cpu
		
		if s.cpu:
			s.info_player.id = "cpu"
		else:
			s.info_player.id = s.name
		array_players.append(from_spawner_to_infoplayer(s))
		i += 1
		
	for info in array_players:
		print_debug(info.to_dict())
	
	if game_mode.cumulative:
		score_to_win_override = len(get_tree().get_nodes_in_group('cell'))
	
	scores.initialize(array_players, game_mode, score_to_win_override, match_duration_override)
	
	
	# initialize HUD
	hud.initialize(scores)
	
	camera.initialize(compute_arena_size())
	
	
	$Battlefield.visible = false
	get_tree().paused = true
	mode_description.gamemode = game_mode
	mode_description.appears()
	if demo:
		# demo will wait 1 second and create a CPU match
		mode_description.demomode(demo)
		mode_description.set_process_input(false)
		yield(get_tree().create_timer(3), "timeout")
		mode_description.disappears()
	yield(mode_description, "ready_to_fight")
	$Battlefield.visible = true
	hud.set_planet("", game_mode)
	
	# FIXME
	grid.init_grid(compute_arena_size().size, $Battlefield/Background/OutsideWall.get_gshape().center_offset)
	
	# set up hive cells
	#for cell in get_tree().get_nodes_in_group('cell'):
	#	var skip = false
	#	for player_spawner in $SpawnPositions/Players.get_children():
	#		if (cell.position - player_spawner.position).length() < 600:
	#			skip = true
	#			break
	#	
	#	if skip:
	#		continue
	#	
	#	if pow(randf(),2) > 0.95:
	#		var wall = wall_scene.instance()
	#		var gshape = cell.get_gshape()
	#		cell.remove_child(gshape)
	#		wall.add_child(gshape)
	#		wall.position = cell.position
	#		wall.rotation = cell.rotation
	#		#wall.fill_color = Color(0.8,0.8,0.8,1)
	#		#wall.modulate = Color(0.5,0.5,0.5,1)
	#		wall.scale = Vector2(0.8,0.8)
	#		$Battlefield.add_child(wall)
	#		cell.queue_free()
	
	if not mockup:
		Soundtrack.play("Fight", true)
	else:
		hud.visible = false
	if not mockup:
		var j = 0
		var player_spawners = $SpawnPositions/Players.get_children()
		for s in player_spawners:
			var spawner = s as PlayerSpawner
			spawner.appears()
			# waiting for the ship to be entered
			yield(get_tree().create_timer(0.5), "timeout")
			spawn_ship(spawner)
			j += 1
			# wait for the last ship
			if j >= len(player_spawners):
				yield(spawner, "entered_battlefield")
		get_tree().paused = false
		camera.activate_camera()

	else:
		spawn_ships()
	
	yield(get_tree().create_timer(0.1), "timeout") # FIXME workaround to wait for all ships

	# setup Bomb spawners
	for c in $Battlefield/Foreground.get_children():
		print_debug(c.name)
	for bomb_spawner in get_tree().get_nodes_in_group("spawner"):
		bomb_spawner.initialize(self)
		if bomb_spawner.owned_by_player and $Battlefield/Foreground.has_node(bomb_spawner.owned_by_player):
			bomb_spawner.owner_ship = $Battlefield/Foreground.get_node(bomb_spawner.owned_by_player)

		bomb_spawner.spawn()
	for turret in get_tree().get_nodes_in_group("turret"):
		turret.initialize(self)
		
	update_time_scale()

func focus_in_camera(node: Node2D, wait_time: float):
	focus_in_camera.move(node.position, wait_time)
	
const COUNTDOWN_LIMIT = 5.0

func _process(delta):
	scores.update(delta)
	
	slomo()
	
	if int(scores.time_left) == COUNTDOWN_LIMIT -1 and not $CanvasLayer/Countdown/AudioStreamPlayer.playing:
		$CanvasLayer/Countdown/AudioStreamPlayer.play()
	if scores.time_left < COUNTDOWN_LIMIT and scores.time_left > 0:
		$CanvasLayer/Countdown.text = str(int(ceil(scores.time_left)))
	else:
		$CanvasLayer/Countdown.text = ""

func _input(event):
	if demo:
		if event is InputEventKey or event is InputEventJoypadButton:
			emit_signal("back_to_menu")
			
func _unhandled_input(event):
		
	if event.is_action_pressed("force_pause"):
		pause.start()
		
	if event.is_action_pressed("pause") and not global.demo:
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
	print_debug("Windows changed")

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
	if $CrownModeManager.enabled:
		if len(ECM.entities_with('Royal')) > 0:
			if ECM.E(ship).has('Royal'):
				respawn_timeout = 3
			else:
				respawn_timeout = 1
	elif $ConquestModeManager.enabled:
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
	game_over.initialize(winner, scores, global.win)
	for team in scores:
		var player = scores[team]
		var stats =player.to_stats() 
		for key in stats:
			global.send_stats("design", {"event_id": "gameplay:{key}:{id}".format({"key": key, "id": player.id}), "value": stats[key]}) 

onready var combat_manager = $CombatManager
onready var stun_manager = $StunManager
onready var collect_manager = $CollectManager
onready var environments_manager = $EnvironmentsManager
onready var crown_mode_manager = $CrownModeManager
onready var deathmatch_mode_manager = $DeathmatchModeManager
onready var conquest_manager = $ConquestManager
onready var pursue_manager = $PursueManager
onready var collect_mode_manager = $CollectModeManager
onready var snake_trail_manager = $TrailManager

const ship_scene = preload("res://actors/battlers/Ship.tscn")
const cpu_ship_scene = preload("res://actors/battlers/CPUShip.tscn")
const trail_scene = preload("res://actors/battlers/TrailNode.tscn")

onready var focus_in_camera = $Battlefield/Overlay/ElementInCamera

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
	ship.info_player = player.info_player
	yield(player, "entered_battlefield")
	
	$Battlefield.add_child(ship)
	
	# create and link trail
	var trail = trail_scene.instance()
	trail.initialize(ship)
	
	$Battlefield.add_child(trail)
	yield(trail, "ready")
	# Check on gears
	ship.set_bombs_enabled(game_mode.shoot_bombs)
	trail.configure(game_mode.deadly_trails)
	print("bombs? ", ship.bombs_enabled)
	print("trail deadly= ", trail.is_deadly())

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
	ship.connect("near_area_entered", conquest_manager, "_on_ship_collided")
	ship.connect("near_area_entered", snake_trail_manager, "_on_ship_collided")
	
	$CrownModeManager.connect('show_score', ship, "update_score")
	
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

const points_scored_scene = preload('res://special_scenes/on_canvas_ui/PointsScored.tscn')
func spawn_points_scored(species_template, score, pos):
	var points_scored = points_scored_scene.instance()
	points_scored.set_points(score)
	points_scored.scale = camera.zoom
	points_scored.position = pos
	points_scored.modulate = species_template.color
	$Battlefield.add_child(points_scored)

func _on_sth_collected(collector, collectee):
	if collectee.get_parent().is_in_group("spawner_group"):
		collectee.get_parent().call_deferred('remove', collectee)
	else:
		$Battlefield.call_deferred('remove_child', collectee) # collisions do not work as expected without defer

func _on_sth_dropped(dropper, droppee):
	$Battlefield.add_child(droppee)
	droppee.position = dropper.position
	droppee.linear_velocity = dropper.linear_velocity
	
	# wait a bit, then make the item collectable again
	yield(get_tree().create_timer(0.2), "timeout")
	ECM.E(droppee).get('Collectable').enable()
	
#func _on_coins_dropped(dropper, amount):
#	for i in range(amount):
#		var coin = coin_scene.instance()
#		$Battlefield.add_child(coin)
#		coin.position = dropper.position
#		coin.linear_velocity = dropper.linear_velocity + Vector2(500,0).rotated(randi()/8/PI)

func _on_coins_finished(diamonds, wait_time=1):
	if wait_time:
		focus_in_camera.move(diamonds.position, wait_time)
		yield(focus_in_camera, "completed") 
	diamonds.spawn()
	collect_mode_manager.on_wave_ready()
	
	#for collectable in collectables:
	#	$Battlefield.add_child(collectable)
		
func _on_Pause_back_to_menu():
	emit_signal("back_to_menu")

func _on_GameOver_rematch():
	emit_signal("rematch")

func _on_Pause_restart():
	emit_signal("restart")

func _on_Pause_skip():
	emit_signal("rematch") # WARNING this should be different if we are keeping scores
	
const max_slomo_elements = 6
func slomo():
	if len(get_tree().get_nodes_in_group('slomo')) > max_slomo_elements:
		self.time_scale = lerp(time_scale, 0.5, 0.2)
	else:
		self.time_scale = lerp(time_scale, 1, 0.1)
		