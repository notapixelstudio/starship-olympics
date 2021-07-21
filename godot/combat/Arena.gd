tool
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
export var style : Resource setget set_style
export var planet_name : String

export var underwater : bool = false

export var score_to_win_override : int = 0
export var match_duration_override : float = 0

export var show_hud : bool = true
export var show_intro : bool = true

var debug = false
# analytics
var run_time = 0

onready var crown_mode = $Managers/CrownModeManager
onready var kill_mode = $Managers/KillModeManager
onready var last_man_mode = $Managers/LastManModeManager
onready var conquest_mode = $Managers/ConquestModeManager
onready var collect_mode = $Managers/CollectModeManager
onready var survival_mode = $Managers/SurvivalModeManager

onready var combat_manager = $Managers/CombatManager
onready var stun_manager = $Managers/StunManager
onready var collect_manager = $Managers/CollectManager
onready var environments_manager = $Managers/EnvironmentsManager
onready var conquest_manager = $Managers/ConquestManager
onready var pursue_manager = $Managers/PursueManager
onready var snake_trail_manager = $Managers/TrailManager

onready var SpawnPlayers = $SpawnPositions/Players
onready var camera = $Camera
onready var canvas = $CanvasLayer
onready var hud = $CanvasLayer/HUD
onready var pause = $CanvasLayer/Pause
onready var mode_description = $CanvasLayer/DescriptionMode
onready var grid = $Battlefield/Background/GridWrapper/Grid
onready var deathflash_scene = preload('res://actors/battlers/DeathFlash.tscn')
onready var element_in_camera_scene = preload("res://actors/environments/ElementInCamera.tscn")

var standalone : bool = true
onready var battlefield = $Battlefield

signal screensize_changed(screensize)
signal gameover
signal restart
signal continue_session
signal back_to_menu
signal slomo
signal unslomo
signal battle_start
signal skip

var array_players = [] # Dictionary of InfoPlayers

func compute_arena_size():
	"""
	compute the battlefield size
	"""
	return $Battlefield/Background/OutsideWall.get_rect_extents()

func set_time_scale(value):
	time_scale = value
	update_time_scale()
	
func set_style(v : ArenaStyle):
	style = v
	
	if not is_inside_tree():
		yield(self, 'ready')
	
	for wall in get_tree().get_nodes_in_group('wall'):
		wall.solid_line_color = style.wall_color
		wall.line_texture = style.wall_texture
	for grid in get_tree().get_nodes_in_group('grid'):
		grid.fg_color = style.battlefield_fg_color
		grid.fg_color = style.battlefield_fg_color
		grid.bg_color = style.battlefield_bg_color
		grid.modulate.a = style.battlefield_opacity
		grid.poly.texture = style.battlefield_texture
		grid.poly.texture_offset = style.battlefield_texture_offset
		grid.poly.texture_scale = style.battlefield_texture_scale
		grid.poly.texture_rotation_degrees = style.battlefield_texture_rotation_degrees
		
func get_time_scale():
	return time_scale
	
func update_time_scale():
	Engine.time_scale = time_scale

signal update_stats

func setup_level(mode : Resource):
	assert(mode is GameMode)
	# mode managers
	crown_mode.enabled = mode.crown
	kill_mode.enabled = mode.death
	last_man_mode.enabled = mode.last_man
	collect_mode.enabled = mode.collect
	conquest_mode.enabled = mode.hive
	survival_mode.enabled = mode.survival
	
	# managers
	pursue_manager.enabled = mode.pursuing_bombs
	
	#FIX
	if global.session and mode.name in global.session.get_settings() and not global.campaign_mode:
		for key in global.session.get_settings(mode.name):
			var val = global.session.get_settings(mode.name)[key]
			mode.set(key, val)
			# send stats for settings
			global.send_stats("design", {"event_id": "settings:{what}:{sport}".format({"what": key, "sport": mode.name}), "value": int(val)})
	
func _init():
	global.arena = self

	# Initialize the match
	global.new_match()
	global.the_match.connect("game_over", self, "on_gameover")
	connect("update_stats", global.the_match, "update_stats")
	
func _ready():
	set_process(false)
	
	# remove HUD if not needed (e.g., map)
	if not show_hud:
		$CanvasLayer/HUD.queue_free()
	
	# Pick controller label
	$CanvasLayer/DemoLabel.visible = demo
	
	Soundtrack.fade_out()
	
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

	
	connect("slomo", environments_manager, "activate_slomo", [self], CONNECT_ONESHOT)
	
	
	collect_manager.connect('collected', crown_mode, "_on_sth_collected")
	collect_manager.connect('collected', self, "_on_sth_collected")
	collect_manager.connect('dropped', crown_mode, "_on_sth_dropped")
	collect_manager.connect('dropped', self, "_on_sth_dropped")
	collect_manager.connect("stolen", crown_mode, "_on_sth_stolen")
	collect_manager.connect("stolen", self, "_on_sth_stolen")
	environments_manager.connect('repel_cargo', collect_manager, "_on_cargo_repelled")
	collect_manager.connect('collected', collect_mode, "_on_sth_collected")
	collect_manager.connect('coins_dropped', collect_mode, "_on_coins_dropped")
	collect_manager.connect('coins_dropped', self, "_on_coins_dropped")
	conquest_manager.connect('conquered', conquest_mode, "_on_sth_conquered")
	conquest_manager.connect('lost', conquest_mode, "_on_sth_lost")
	
	combat_manager.connect('show_msg', self, "show_msg")
	
	# This won't be needed anymore, since the_match will be global
	"""
	crown_mode.connect('score', scores, "add_score")
	kill_mode.connect('score', scores, "add_score")
	kill_mode.connect('broadcast_score', scores, "broadcast_score")
	kill_mode.connect('show_msg', self, "show_msg")
	last_man_mode.connect('broadcast_score', scores, "broadcast_score")
	race_mode.connect('score', scores, "add_score")
	conquest_mode.connect('score', scores, "add_score")
	collect_mode.connect('score', scores, "add_score")
	goal_mode.connect('score', scores, "add_score")
	survival_mode.connect('score', scores, "add_score")
	"""
	
	kill_mode.connect('show_msg', self, "show_msg")
	conquest_mode.connect('show_msg', self, "show_msg")
	collect_mode.connect('show_msg', self, "show_msg")
	
	for goal in traits.get_all_with('Goal'):
		goal.connect('goal_done', self, '_on_goal_done')
		
	
	var players = {}
	var array_players = []
	
	if global.session:
		array_players = global.session.get_players().values()
		standalone = false
	else:
		global.session = TheSession.new()
	
	var spawners = $SpawnPositions/Players.get_children()
	# Randomize player position at start: https://github.com/notapixelstudio/superstarfighter/issues/399
	# works with a session, not if you run from scene
	spawners.shuffle()
	# set up the spawners
	var i = 0
	for s in spawners:
		var key = s.name
		var info_player = InfoPlayer.new()
		if standalone:
			
			info_player.cpu = s.cpu
			info_player.species = s.species
			info_player.controls = s.controls
			if s.cpu:
				info_player.id = "cpu"+str(i+1)
			else:
				info_player.id = s.name
			
		else:
			info_player = array_players[i] 
			s.controls = info_player.controls
			s.species = info_player.species
			s.cpu = info_player.cpu
		
		players[info_player.id] = info_player
		
		# setup teams
		if s.team and s.team != '':
			info_player.team = s.team
		elif not info_player.team:
			info_player.team = info_player.id
			
		s.set_info_player(info_player)
		i += 1
	
	global.session.set_players(players)
	
	if conquest_mode.enabled:
		var conquerables = traits.get_all_with('Conquerable')
		if len(conquerables) > 0:
			score_to_win_override = 0
			for conquerable in conquerables:
				score_to_win_override += conquerable.get_score()
				# connect to manager
				conquerable.connect('conquered', conquest_mode, "_on_sth_conquered")
				conquerable.connect('lost', conquest_mode, "_on_sth_lost")
				
	# FIXME this should eventually replace the system above
	var score_definers = traits.get_all_with('ScoreDefiner')
	if len(score_definers) > 0:
		score_to_win_override = 0
		for score_definer in score_definers:
			score_to_win_override += score_definer.get_score()
	
	global.the_match.initialize(players, game_mode, score_to_win_override, match_duration_override)
	
	if show_hud:
		# initialize HUD
		hud.post_ready()
	
	# adapt camera to hud height
	if show_hud:
		camera.marginY = hud.get_height()
	camera.initialize(compute_arena_size())
	
	# $Battlefield.visible = false
	if score_to_win_override > 0:
		game_mode.max_score = score_to_win_override
	if match_duration_override > 0:
		game_mode.max_timeout = match_duration_override
		
	if show_intro:
		mode_description.gamemode = game_mode
		mode_description.appears()
		if demo:
			# demo will wait 1 second and create a CPU match
			mode_description.demomode(demo)
			mode_description.set_process_input(false)
			yield(get_tree().create_timer(3), "timeout")
			mode_description.disappears()
	
	update_grid()
	grid.set_max_timeout(game_mode.max_timeout)
	grid.clock = game_mode.survival
	if grid.clock:
		grid.add_to_group('in_camera')
	
	# FIXME
	for well in get_tree().get_nodes_in_group('gravity_wells_on'):
		well.enabled = true

	var ships = []
	
	# environment spawner: coins, etc.
	if get_tree().get_nodes_in_group("spawner_group"):
		focus_in_camera.activate()
		
	# connect already placed killable stuff (bricks, aliens, etc.)
	for sth in get_tree().get_nodes_in_group("killables"):
		connect_killable(sth)
		
	# manage level flooding
	if (global.flood == "on" and game_mode.floodable) or (global.flood == "random" and game_mode.floodable and randf() < 0.33) or game_mode.flood or underwater:
		if not underwater:
			var level_height = compute_arena_size().size.y
			var water_rect_height = $Battlefield/Background/FloodWater/GRect.height
			$Battlefield/Background/FloodWater.position.y = water_rect_height/2 + level_height/2
			var flood_animation =  $Battlefield/Background/FloodWater/AnimationPlayer.get_animation('Rotate')
			flood_animation.track_set_key_value(0, 0, Vector2(0, water_rect_height/2 + level_height/2))
			flood_animation.track_set_key_value(0, 1, Vector2(0, water_rect_height/2 - level_height/2))
			flood_animation.track_set_key_time(0, 1, game_mode.max_timeout) # filled as the countdown is done
		else:
			$Battlefield/Background/FloodWater/AnimationPlayer.queue_free()
			$Battlefield/Background/FloodWater.position.y = 0
	else:
		$Battlefield/Background/FloodWater.queue_free()
		
	# manage level lasering
	if (global.laser== "on" and game_mode.laserable) or (global.laser == "random" and game_mode.laserable and randf() < 0.33) or game_mode.additional_lasers:
		for laser_anim in get_tree().get_nodes_in_group('animation_if_additional_lasers'):
			laser_anim.play('Default')
	else:
		for laser in get_tree().get_nodes_in_group('additional_lasers'):
			laser.queue_free()
		
	# load style from gamemode, if specified
	if game_mode.arena_style:
		set_style(game_mode.arena_style)
		
	if show_intro:
		yield(mode_description, "ready_to_fight")
	if show_hud:
		hud.set_planet("", game_mode)
	
	if style and style.bgm:
		Soundtrack.play(style.bgm, true)
	else:
		Soundtrack.stop()
	
	var j = 0
	var player_spawners = $SpawnPositions/Players.get_children()

	for s in player_spawners:
		var spawner = s as PlayerSpawner
		spawner.appears()
		# waiting for the ship to be entered
		yield(get_tree().create_timer(0.5), "timeout")
		ships.append(spawn_ship(spawner))
		j += 1
		# wait for the last ship
		if j >= len(player_spawners):
			yield(spawner, "entered_battlefield")
	
	camera.activate_camera()
	
	yield(get_tree(), "idle_frame") # FIXME workaround to wait for all ships
	
	# group by order for trait intro
	var intro_nodes = {}
	for trait in traits.get_all('Intro'):
		if not(str(trait.order) in intro_nodes.keys()):
			intro_nodes[str(trait.order)] = []
		intro_nodes[str(trait.order)].append(trait.get_host())
	
	for group in intro_nodes:
		for node in intro_nodes[group]:
			node.intro()
		for node in intro_nodes[group]:
			yield(node, 'done')
	
	for bomb_spawner in get_tree().get_nodes_in_group("spawner"):
		bomb_spawner.initialize(self)
		if bomb_spawner.owned_by_player and $Battlefield/Foreground.has_node(bomb_spawner.owned_by_player):
			bomb_spawner.owner_ship = $Battlefield/Foreground.get_node(bomb_spawner.owned_by_player)

		bomb_spawner.spawn()
	for turret in get_tree().get_nodes_in_group("turret"):
		turret.initialize(self)
		
	update_time_scale()
	set_process(true)
	for anim in get_tree().get_nodes_in_group("animation_in_battle"):
		anim.play("Rotate")
		
	emit_signal('battle_start')
	
	for node in traits.get_all_with("Waiter"):
		node.start()
		
func focus_in_camera(node: Node2D, wait_time: float):
	focus_in_camera.move(node.position, wait_time)

const COUNTDOWN_LIMIT = 5.0

func update_grid():
	# TODO: maybe you can put directly inside grid
	grid.set_points($Battlefield/Background/OutsideWall.get_gshape().to_PoolVector2Array())
	grid.set_t(global.the_match.time_left)
	
func _process(delta):
	if Engine.is_editor_hint():
		return
		
	global.the_match.update(delta)
	update_grid()
	slomo()
	
	if int(global.the_match.time_left) == COUNTDOWN_LIMIT -1 and not $CanvasLayer/Countdown/AudioStreamPlayer.playing:
		# no countdown speaker right now. ISSUE #485
		# $CanvasLayer/Countdown/AudioStreamPlayer.play()
		pass
	if global.the_match.time_left < COUNTDOWN_LIMIT and global.the_match.time_left > 0:
		$CanvasLayer/Countdown.text = str(int(ceil(global.the_match.time_left)))
	else:
		$CanvasLayer/Countdown.text = ""

func _input(event):
	if demo:
		if event is InputEventKey or event is InputEventJoypadButton:
			emit_signal("back_to_menu")
			
func _unhandled_input(event):
	if event.is_action_pressed("pause") and not global.demo and not global.the_match.game_over:
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

func ship_just_died(ship, killer, for_good):
	"""
	Parameters
	----------
		ship : Ship
		killer: Ship
		
	"""
	
	if for_good:
		# this needs to be deferred, to make other listeners fire first
		call_deferred('unregister_ship', ship)
	
	# stats
	# TODO: maybe somewhere else
	emit_signal("update_stats", ship.info_player, 1, "deaths")
	if killer and killer is Ship and killer != ship:
		emit_signal("update_stats", killer.info_player, 1, "kills")
	else:
		emit_signal("update_stats", ship.info_player, 1, "selfkills")
	
	$Battlefield.call_deferred("remove_child", ship)
	
	var deathflash = deathflash_scene.instance()
	deathflash.species = ship.species
	deathflash.position = ship.position
	$Battlefield.call_deferred("add_child", deathflash)
	
	if not for_good:
		$Battlefield.call_deferred("add_child", ship.dead_ship_instance)
		
		ship.dead_ship_instance.apply_central_impulse(-ship.linear_velocity*0.5)
		ship.dead_ship_instance.apply_torque_impulse(ship.linear_velocity.length())
	
	var focus
	
	if ship.info_player.lives == 0:
		var alive_players = []
		if not for_good:
			focus = load("res://actors/environments/ElementInCamera.tscn").instance()
			ship.dead_ship_instance.remove_from_group("in_camera")
			$Battlefield.add_child(focus)
		yield(get_tree(), "idle_frame")
		
		for s in get_tree().get_nodes_in_group('players'):
			if s.alive:
				alive_players.append(s)
				
		if not for_good:
			focus.manual_activate($CenterCamera, ship.dead_ship_instance.position, len(alive_players))
		
		if len(alive_players) == 1:
			# notify scores if there is only one player left
			yield(get_tree().create_timer(1), 'timeout')
			# Used with old survival rules
			# scores.one_player_left(alive_players[0].info_player)
			
		elif len(alive_players) == 0:
			# notify scores if there are no players left
			yield(get_tree().create_timer(0.3), 'timeout')
			global.the_match.no_players_left()
			
		# shrink the battlefield in last man standing
		if game_mode.last_man:
			if len(alive_players) == 3:
				$LastManAnimationPlayer.play('Shrink')
			elif len(alive_players) == 2:
				yield($LastManAnimationPlayer, 'animation_finished')
				$LastManAnimationPlayer.play('Shrink2')
		
		# skip respawn if there are no lives left
		return
		
	# skip respawn if the ship died for good
	if for_good:
		ship.trail.maybe_erase()
		ship.queue_free()
		return
	
	var respawn_timeout = 1.5
	if game_mode.id == 'crown' or game_mode.id == 'queen_of_the_hive':
		if len(ECM.entities_with('Royal')) > 0:
			if ECM.E(ship).has('Royal'):
				respawn_timeout = 2.25
			else:
				respawn_timeout = 0.75
	elif conquest_mode.enabled:
		respawn_timeout = 0.75
	elif game_mode.name == "GoalPortal":
		respawn_timeout = 0.75
	
	yield(get_tree().create_timer(respawn_timeout), "timeout")
	
	if global.the_match.game_over:
		return
	
	# respawn
	
	ship.linear_velocity = ship.dead_ship_instance.linear_velocity
	ship.angular_velocity = ship.dead_ship_instance.angular_velocity
	$Battlefield.call_deferred("remove_child", ship.dead_ship_instance)
	ship.position = ship.dead_ship_instance.position
	ship.rotation = ship.dead_ship_instance.rotation
	$Battlefield.call_deferred("add_child", ship)
	create_trail(ship)
	
	
func on_gameover():
	if demo:
		emit_signal("back_to_menu")
		return
	for child in $Managers.get_children():
		if child is ModeManager:
			child.enabled = false
	camera.stop_and_zoomout(compute_arena_size())
	$GameOverAnim.play('Game Over')
	yield($GameOverAnim, "animation_finished") # wait for animation and UI redraw (esp. bars)
	set_time_scale(1)
	get_tree().paused = true
	var game_over = gameover_scene.instance()
	game_over.connect("pressed_continue", self, "_on_Continue_session")
	game_over.connect("back_to_menu", self, "_on_Pause_back_to_menu")
	game_over.connect("show_arena", self, "_on_Show_Arena")
	game_over.connect("hide_arena", self, "_on_hide_Arena")
	canvas.add_child(game_over)
	
	game_over.initialize()

func _on_Continue_session():
	if standalone:
		# forced session to null
		global.session = null
		get_tree().paused = false
		get_tree().reload_current_scene()
	emit_signal("continue_session")
	
func _on_Show_Arena():
	$Battlefield/Background.modulate = Color(1,1,1,1)
	$Battlefield/Middleground.modulate=Color(1,1,1,1)
	$BackgroundLayer.get_child(0).modulate=Color(1,1,1,1)

func _on_hide_arena():
	$Battlefield/Background.modulate=Color(0.33,0.33,0.33,1)
	$Battlefield/Middleground.modulate=Color(0.33,0.33,0.33,1)
	$BackgroundLayer.get_child(0).modulate=Color(0.33,0.33,0.33,1)
	
const ship_scene = preload("res://actors/battlers/Ship.tscn")
const cpu_ship_scene = preload("res://actors/battlers/CPUShip.tscn")
const trail_scene = preload("res://actors/battlers/TrailNode.tscn")

onready var focus_in_camera = $Battlefield/Overlay/ElementInCamera

func spawn_ships():
	for player in SpawnPlayers.get_children():
		spawn_ship(player)

func create_trail(ship):
	# create and link trail
	var trail = trail_scene.instance()
	$Battlefield.add_child(trail)
	yield(trail, "ready")
	trail.initialize(ship)
	trail.configure(ship.get_deadly_trail(), game_mode.deadly_trails_duration)
	ship.trail = trail
	return trail

signal ship_spawned
func spawn_ship(player:PlayerSpawner, force_intro=false):
	var ship : Ship
	if player.is_cpu():
		ship = cpu_ship_scene.instance()
	else:
		ship = ship_scene.instance()
	
	ship.camera = camera
	ship.controls = player.controls
	ship.species = player.species
	ship.position = player.position
	ship.rotation = player.rotation
	ship.height = height
	ship.width = width
	ship.name = player.name
	ship.info_player = player.info_player
	ship.spawner = player
	ship.deadly_trail = game_mode.deadly_trails
	ship.game_mode = self.game_mode
	yield(player, "entered_battlefield")
	
	$Battlefield.add_child(ship)
	
	create_trail(ship)
	yield(get_tree(), "idle_frame") # FIXME this is needed for set_bomb_type
	register_ship(ship)
	emit_signal('ship_spawned', ship)
	
	if force_intro:
		ship.intro()
	
	# smoothly transition 
	var focus = element_in_camera_scene.instance()
	$Battlefield.add_child(focus)
	yield(get_tree(), "idle_frame")
	ship.remove_from_group("in_camera")
	focus.manual_activate(ship, global.calculate_center(camera.camera_rect), 1)
	yield(focus, "completed")
	ship.add_to_group("in_camera")
	
	
	# Check on gears
	ship.set_bombs_enabled(game_mode.shoot_bombs)
	ship.set_default_bomb_type(game_mode.bomb_type)
	ship.set_ammo(game_mode.starting_ammo)
	ship.set_reload_time(game_mode.reload_time)
	ship.set_lives(game_mode.starting_lives)
	
	
	# connect signals
	ship.connect("dead", self, "ship_just_died")
	ship.connect("frozen", self, "_on_sth_just_froze")
	ship.connect("spawn_bomb", self, "spawn_bomb", [ship])
	ship.connect("near_area_entered", combat_manager, "_on_ship_collided")
	ship.connect("body_entered", combat_manager, "_on_ship_collided", [ship])
	ship.connect("body_entered", collect_manager, "ship_sth_entered", [ship])
	ship.connect("near_area_entered", collect_manager, "ship_sth_entered")
	ship.connect("body_entered", environments_manager, "_on_sth_entered", [ship])
	ship.connect("near_area_entered", environments_manager, "_on_sth_entered")
	ship.connect("near_area_exited", environments_manager, "_on_sth_exited")
	ship.connect("detection", pursue_manager, "_on_ship_detected")
	ship.connect("body_entered", stun_manager, "ship_collided", [ship])
	ship.connect("dead", kill_mode, "_on_sth_killed")
	ship.connect("dead", last_man_mode, "_on_sth_killed")
	#ship.connect("dead", combat_manager, "_on_sth_killed")
	ship.connect("dead", collect_manager, "_on_ship_killed")
	ship.connect("near_area_entered", conquest_manager, "_on_ship_collided")
	ship.connect("fallen", self, "_on_ship_fallen")
	ship.connect('thrusters_on', self, '_on_ship_thrusters_on', [ship])
	
	# attach followcamera
	var follow = load("res://actors/battlers/FollowCamera.tscn").instance()
	follow.node_owner = ship.get_node("TargetDest")
	follow.add_to_group("in_camera")
	$Battlefield.add_child(follow)
	ship.connect("dead", follow, "ship_just_died")
	
	
	crown_mode.connect('show_msg', ship, "update_score")
	return ship
	
const bomb_scene = preload('res://actors/weapons/Bomb.tscn')
const mine_scene = preload('res://combat/collectables/Mine.tscn')
const wave_scene = preload('res://actors/weapons/ShockWave.tscn')
func spawn_bomb(type, symbol, pos, impulse, ship, size=1):
	var bomb
	if type == GameMode.BOMB_TYPE.mine:
		bomb = mine_scene.instance()
		bomb.set_owner_ship(ship)
		bomb.position = ship.global_position
		bomb.apply_central_impulse(impulse)
	elif type == GameMode.BOMB_TYPE.wave:
		bomb = wave_scene.instance()
		bomb.set_owner_ship(ship)
		bomb.position = ship.global_position
		bomb.rotation = ship.global_rotation+PI
		bomb.speed = 350 + impulse.length()/3
		bomb.angle = PI/3 + impulse.length()/4000
	else:
		bomb = bomb_scene.instance()
		bomb.initialize(type, pos, impulse, ship, size)
		if symbol:
			bomb.symbol = symbol
		
		bomb.connect("near_area_entered", combat_manager, "bomb_near_area_entered")
		bomb.connect("near_area_entered", environments_manager, "_on_sth_entered")
		bomb.connect("near_area_exited", environments_manager, "_on_sth_exited")
		bomb.connect("detonate", self, "bomb_detonated", [bomb])
		bomb.connect("expired", ship, "_on_bomb_expired")
	
	$Battlefield.add_child(bomb)
	
	if ship:
		emit_signal("update_stats", ship.info_player, 1, "bombs")
	
	return bomb

func bomb_detonated(bomb):
	grid.add_well(bomb)
	
const message_scene = preload('res://special_scenes/on_canvas_ui/FloatingMessage.tscn')

func show_msg(species: Species, msg, pos):
	var msg_node = message_scene.instance()
	msg_node.set_msg(msg)
	msg_node.scale = camera.zoom
	msg_node.position = pos
	msg_node.modulate = species.color
	$Battlefield.add_child(msg_node)

func _on_sth_collected(collector, collectee):
	if collectee is Crown and (collectee.type == Crown.types.SOCCERBALL or collectee.type == Crown.types.TENNISBALL):
		collectee.owner_ship = collector
		
	if collectee.get_parent().is_in_group("spawner_group"):
		collectee.get_parent().call_deferred('remove', collectee)
	else:
		$Battlefield.call_deferred('remove_child', collectee) # collisions do not work as expected without defer
		
func _on_sth_dropped(dropper, droppee):
	$Battlefield.add_child(droppee)
	droppee.position = dropper.position
	if dropper is Ship:
		droppee.linear_velocity = dropper.previous_velocity # this is used with glass walls
		if droppee is Crown and droppee.type != Crown.types.CROWN: # balls are held in front of the ship
			droppee.position += Vector2(Crown.GRAB_DISTANCE,0).rotated(dropper.rotation)
	else:
		droppee.linear_velocity = dropper.linear_velocity
		
	if droppee.has_method('start'):
		droppee.start()
		
	if droppee is Crown and droppee.type == Crown.types.SOCCERBALL:
		droppee.linear_velocity *= 1.5
		
	# wait a bit, then make the item collectable again
	yield(get_tree().create_timer(0.2), "timeout")
	ECM.E(droppee).get('Collectable').enable()
	# retrigger bodies already entered
	yield(get_tree().create_timer(0.5), "timeout")
	dropper.recheck_colliding()
	
func _on_sth_stolen(thief, mugged):
	var what = ECM.E(mugged).get('Cargo').what
	if what is Crown and what.type == Crown.types.SOCCERBALL:
		what.owner_ship = thief
		
#func _on_coins_dropped(dropper, amount):
#	for i in range(amount):
#		var coin = coin_scene.instance()
#		$Battlefield.add_child(coin)
#		coin.position = dropper.position
#		coin.linear_velocity = dropper.linear_velocity + Vector2(500,0).rotated(randi()/8/PI)

signal wave_ready

func on_next_wave(diamonds, wait_time=1):
	if wait_time:
		focus_in_camera.move(diamonds.position, wait_time)
		yield(focus_in_camera, "completed")
	diamonds.spawn()
	emit_signal('wave_ready')
	
func _on_Pause_back_to_menu():
	emit_signal("back_to_menu")

func _on_Pause_restart():
	emit_signal("restart")

func _on_Pause_skip():
	emit_signal("skip") # WARNING this should be different if we are keeping scores
	
const max_slomo_elements = 7

func slomo():
	
	if len(get_tree().get_nodes_in_group('slomo')) > max_slomo_elements:
		emit_signal("slomo")
		self.time_scale = lerp(time_scale, 0.5, 0.2)
	else:
		emit_signal("unslomo")
		self.time_scale = lerp(time_scale, 1, 0.1)
		
func _on_Rock_request_spawn(child):
	if child is Rock:
		child.connect('request_spawn', self, '_on_Rock_request_spawn')
		child.connect('conquered', conquest_mode, '_on_sth_conquered')
		child.connect('lost', conquest_mode, '_on_sth_lost')
	$Battlefield.add_child(child)

func _on_EndlessArea_body_exited(body):
	if is_instance_valid(body):
		body.queue_free()
		
func _on_ship_fallen(ship, spawner):
	ship.trail.destroy()
	ship.die(null, true) # die for good
	yield(get_tree().create_timer(1), "timeout")
	spawner.appears()
	spawn_ship(spawner, true) # force intro
	
func connect_killable(killable):
	killable.connect('killed', kill_mode, '_on_sth_killed')
	killable.connect('killed', combat_manager, '_on_sth_killed')
	
func _on_ship_thrusters_on(ship):
	create_trail(ship)

const RockScene = preload('res://actors/environments/Rock.tscn')
func _on_sth_just_froze(sth):
	$Battlefield.call_deferred("remove_child", sth)
	var rock = RockScene.instance()
	rock.position = sth.position
	rock.order = 1
	if sth is Ship:
		rock.base_size = 80
	rock.ice = true
	rock.deadly = false
	rock.spawn_diamonds = false
	rock.prisoner = sth
	rock.self_destruct = true
	rock.self_destruct_position = 'top'
	rock.lifetime = 6
	rock.angular_velocity = 0
	$Battlefield.call_deferred("add_child", rock)
	rock.connect('request_spawn', self, '_on_Rock_request_spawn')
	rock.call_deferred('start')

func _on_goal_done(player, goal, pos):
	global.the_match.add_score(player.id, goal.get_score())
	show_msg(player.species, goal.get_score(), pos)
	
var Ripple = load('res://actors/weapons/Ripple.tscn')
func show_ripple(pos, size=1):
	var ripple = Ripple.instance()
	ripple.position = pos
	ripple.scale = Vector2(size, size)
	$Battlefield.call_deferred("add_child", ripple)
	
# players -> ships register
var player_ships = {}

func register_ship(ship):
	player_ships[ship.get_player().id] = ship
	
func unregister_ship(ship):
	player_ships.erase(ship.get_player().id)
	
func get_ship_from_player(player):
	return player_ships[player.id]
	
func is_ship_valid(ship):
	return ship in player_ships.values()
	
