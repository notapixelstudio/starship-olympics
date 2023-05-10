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
export (float) var size_multiplier = 2.0
export var game_mode : Resource # Gamemode - might be useful
export var style : Resource setget set_style
export var planet_name : String

export var underwater : bool = false
export var IceScene : PackedScene

export var player_brain_scene : PackedScene
export var cpu_brain_scene : PackedScene
export var NavigationZone_scene : PackedScene

export var diamond_scene : PackedScene

export var score_to_win_override : int = 0
export var match_duration_override : float = 0

export var show_hud : bool = true
export var show_intro : bool = true
export var random_starting_position : bool = true
export var place_ships_at_start : bool = true
export var dark_winter : bool = false

export var create_default_navzone := true

var debug = false
# analytics
var run_time = 0
var time_scale : float = 1.0 setget set_time_scale, get_time_scale

onready var crown_mode = $Managers/CrownModeManager
onready var kill_mode = $Managers/KillModeManager
onready var last_man_mode = $Managers/LastManModeManager
onready var conquest_mode = $Managers/ConquestModeManager
onready var collect_mode = $Managers/CollectModeManager
onready var survival_mode = $Managers/SurvivalModeManager

onready var combat_manager = $Managers/CombatManager
onready var collect_manager = $Managers/CollectManager
onready var environments_manager = $Managers/EnvironmentsManager
onready var conquest_manager = $Managers/ConquestManager
onready var pursue_manager = $Managers/PursueManager
onready var snake_trail_manager = $Managers/TrailManager

onready var camera = $Camera
onready var canvas = $CanvasLayer
onready var hud = $CanvasLayer/HUD
onready var pause = $CanvasLayer2/Pause
onready var mode_description = $CanvasLayer/DescriptionMode
onready var grid = $Battlefield/Background/GridWrapper/Grid
onready var deathflash_scene = preload('res://actors/battlers/DeathFlash.tscn')

export var standalone : bool = true
onready var battlefield = $Battlefield

signal screensize_changed(screensize)
signal gameover
signal restart
signal continue_session
signal slomo
signal unslomo
signal battle_start
signal skip
signal all_ships_spawned

signal salvo

var array_players = [] # Dictionary of InfoPlayers

func compute_arena_size() -> Rect2:
	"""
	compute the battlefield size
	"""
	if $Battlefield/Background.has_node("CameraStartingRect"):
		return $Battlefield/Background/CameraStartingRect.get_rect_extents()
	return $Battlefield/Background/OutsideWall.get_rect_extents()

func set_time_scale(value):
	time_scale = value
	update_time_scale()
	
func set_style(v : ArenaStyle):
	style = v
	
	if not is_inside_tree():
		yield(self, 'ready')
	
	for wall in get_tree().get_nodes_in_group('wall'):
		if wall.overridable_line_color:
			wall.solid_line_color = style.wall_color
		if not wall.line_texture:
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
		
func get_time_scale():	return time_scale
	
func update_time_scale():
	Engine.time_scale = self.time_scale

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
	if global.is_session_running() and mode.name in global.session.get_settings() and not global.campaign_mode:
		for key in global.session.get_settings(mode.name):
			var val = global.session.get_settings(mode.name)[key]
			mode.set(key, val)
			# send stats for settings
			global.send_stats("design", {"event_id": "settings:{what}:{sport}".format({"what": key, "sport": mode.name}), "value": int(val)})
	
func _init():
	global.arena = self
	
func _enter_tree():
	# this happens before descendants _ready() calls
	# but after export vars are set for this node
	# it is needed to actually take the "standalone" export var
	# into consideration
	global.arena = self
	
	Events.connect('navigation_zone_changed', self, '_on_navigation_zone_changed')
	
	if global.is_match_running():
		standalone = false
		
	# create a standalone match
	if standalone:
		global.new_match()
	
	if global.is_match_running():
		global.the_match.connect("game_over", self, "on_gameover", [], CONNECT_ONESHOT)
		connect("update_stats", global.the_match, "update_stats")
		
		Events.connect('continue_after_game_over', self, '_on_continue_after_game_over')
		Events.connect("ask_to_spawn", self, "dramatic_spawn") # e.g. SpawnerManager
	
func _exit_tree():
	Events.disconnect('navigation_zone_changed', self, '_on_navigation_zone_changed')
	
func _ready():
	set_process(false)
	
	# remove HUD if not needed (e.g., map)
	if not show_hud:
		$CanvasLayer/HUD.queue_free()
	else:
		camera.enabled = global.enable_camera
		Soundtrack.fade_out()
		
	# Pick controller label
	$CanvasLayer/DemoLabel.visible = global.demo
	
	
	# Setup goal, Gear and mode managers
	setup_level(game_mode)
	
	# load specialized CPU brain, if any
	var cpu_brain_from_game_mode = game_mode.get_cpu_brain_scene()
	if cpu_brain_from_game_mode:
		cpu_brain_scene = cpu_brain_from_game_mode
	
	camera.zoom *= size_multiplier
	
	# Engine.time_scale = 0.2
	# in order to get the size
	get_tree().get_root().connect("size_changed", self, "compute_arena_size")
	run_time = OS.get_ticks_msec()
	
	# Analytics
	Analytics.start_elapsed_time()

	
	connect("slomo", environments_manager, "activate_slomo", [self], CONNECT_ONESHOT)
	
	
	collect_manager.connect('collected', crown_mode, "_on_sth_collected")
	collect_manager.connect('collected', self, "_on_sth_collected")
	collect_manager.connect('dropped', crown_mode, "_on_sth_dropped")
	collect_manager.connect('dropped', self, "_on_sth_dropped")
	collect_manager.connect("stolen", crown_mode, "_on_sth_stolen")
	collect_manager.connect("stolen", self, "_on_sth_stolen")
	environments_manager.connect('repel_cargo', collect_manager, "_on_cargo_repelled")
	collect_manager.connect('collected', collect_mode, "_on_sth_collected")
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
	
	if global.is_game_running():
		array_players = global.the_game.get_players()
	
	var spawners = get_tree().get_nodes_in_group('player_spawner')
	# Randomize player position at start: https://github.com/notapixelstudio/superstarfighter/issues/399
	# works with a session, not if you run from scene
	if random_starting_position:
		spawners.shuffle()
		
	# set up the spawners
	var i = 0
	for s in spawners:
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
			# skip populating spawners if there are no more players
			if i >= len(array_players):
				break
				
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
		
	# destroy all unassigned player spawners
	for s in spawners:
		if not s.is_assigned():
			s.free()
			
	if standalone and not global.is_game_running():
		# create a fake game
		global.new_game(players.values())
		global.new_session()
	
	if conquest_mode.enabled:
		var conquerables = traits.get_all_with('Conquerable')
		if len(conquerables) > 0:
#			score_to_win_override = 0
			for conquerable in conquerables:
#				score_to_win_override += conquerable.get_score()
				# connect to manager
				conquerable.connect('conquered', conquest_mode, "_on_sth_conquered")
				conquerable.connect('lost', conquest_mode, "_on_sth_lost")
				
	# FIXME this should eventually replace the system above
	if score_to_win_override == 0: # do this only if score is not already overridden
		var score_definers = traits.get_all_with('ScoreDefiner')
		if len(score_definers) > 0:
			score_to_win_override = 0
			for score_definer in score_definers:
				score_to_win_override += score_definer.get_score()
				
		if not game_mode.shared_targets:
			score_to_win_override /= global.the_game.get_number_of_players()
		
	if game_mode.fill_starting_score:
		game_mode.starting_score = score_to_win_override
	
	if global.is_match_running():
		global.the_match.initialize(players, game_mode, score_to_win_override, match_duration_override)
	
	if show_hud:
		# initialize HUD
		hud.post_ready()
	
	# load style from gamemode, if specified
	if game_mode.arena_style:
		set_style(game_mode.arena_style)
		
	# adapt camera to hud height
	if show_hud:
		camera.marginY = hud.get_height()
		
	camera.initialize(compute_arena_size().grow(100*30))
	camera.to(compute_arena_size())
	update_grid()
	
	if show_hud:
		hud.set_draft_card(global.the_match.get_draft_card())
		
	if global.is_match_running():
		var draft_card = global.the_match.get_draft_card()
		
		# set the appropriate background, according to card suits
		if draft_card != null:
			var suit = draft_card.get_suit_top() # TBD different suits
			$'%BackgroundImage'.texture = load("res://combat/levels/background/"+suit+".png")
			
	# update navigation zones if there is at least a cpu
	if global.the_game.get_number_of_cpu_players() > 0:
		if create_default_navzone and has_node('Battlefield/Background/OutsideWall'):
			$Battlefield/Background/OutsideWall.add_child(NavigationZone_scene.instance())
		update_navigation_zones()
	
	yield(camera, "transition_over")
	
	# $Battlefield.visible = false
	if score_to_win_override > 0:
		game_mode.max_score = score_to_win_override
	if match_duration_override > 0:
		game_mode.max_timeout = match_duration_override
		
	if show_intro:
		mode_description.set_gamemode(game_mode)
		mode_description.appears()

		if global.is_match_running():
			mode_description.set_draft_card(global.the_match.get_draft_card())

	
	grid.set_max_timeout(game_mode.max_timeout)
	grid.clock = game_mode.survival
	if grid.clock:
		grid.add_to_group('in_camera')
	
	# FIXME
	for well in get_tree().get_nodes_in_group('gravity_wells_on'):
		well.enabled = true
	
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
			
	if global.is_match_running():
		var draft_card = global.the_match.get_draft_card()
		# manage the coming of winter
		if draft_card != null and draft_card.is_winter():
			var ice = IceScene.instance()
			ice.override_gshape($Battlefield/Background/OutsideWall.get_gshape())
			$Battlefield/Background.add_child(ice)
			if dark_winter:
				ice.modulate = Color(0.55,0.55,0.55)
				
	if show_intro:
		yield(mode_description, "ready_to_fight")
	
	if style and style.bgm:
		Soundtrack.play(style.bgm, true)
	else:
		Soundtrack.stop()
	
	if place_ships_at_start:
		spawn_all_ships()
		yield(self, 'all_ships_spawned')
	
	camera.activate_camera()
	
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
		
	self.time_scale = float(global.time_scale)
	set_process(true)
	for anim in get_tree().get_nodes_in_group("animation_in_battle"):
		anim.play("Rotate")
		
	emit_signal('battle_start')
	Events.emit_signal('battle_start')
	
	for node in traits.get_all_with("Waiter"):
		node.start()
		
func focus_in_camera(node: Node2D, wait_time: float):
	focus_in_camera.move(node.position, wait_time)

const COUNTDOWN_LIMIT = 5.0

func spawn_all_ships(do_intro = false):
	var j = 0
	var player_spawners = get_tree().get_nodes_in_group('player_spawner')
	
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
			
	yield(get_tree(), "idle_frame")
	
	if do_intro:
		for ship in self.get_all_valid_ships():
			ship.intro()
			
	emit_signal("all_ships_spawned", player_spawners)

func update_grid():
	# TODO: maybe you can put directly inside grid
	grid.set_points($Battlefield/Background/OutsideWall.get_gshape().to_PoolVector2Array())
	if global.is_match_running():
		grid.set_t(global.the_match.time_left)
	
func _process(delta):
	if Engine.is_editor_hint():
		return
		
	if global.is_match_running():
		global.the_match.update(delta)
	update_grid()
	#slomo()
	
	if global.is_match_running() and int(global.the_match.time_left) == COUNTDOWN_LIMIT -1 and not $CanvasLayer/Countdown/AudioStreamPlayer.playing:
		# no countdown speaker right now. ISSUE #485
		# $CanvasLayer/Countdown/AudioStreamPlayer.play()
		pass
	if global.is_match_running() and global.the_match.time_left < COUNTDOWN_LIMIT and global.the_match.time_left > 0:
		$CanvasLayer/Countdown.text = str(int(ceil(global.the_match.time_left)))
	else:
		$CanvasLayer/Countdown.text = ""


func _unhandled_input(event):
	if event.is_action_pressed("pause") and not global.demo and (not global.is_match_running() or not global.the_match.game_over):
		pause.start()
		
	var debug_pressed = event.is_action_pressed("debug")
	if debug_pressed:
		debug = not debug
		OS.window_fullscreen = !OS.window_fullscreen
		# DebugNode.visible = debug
		
	# reset by command only through debug
	if event.is_action_pressed('continue') and debug:
		reset(global.level)
		
	if event.is_action_pressed("debug_action") and global.the_match:
		global.the_match.trigger_game_over_now()
	
func reset(level):
	someone_died = false
	get_tree().change_scene_to(load("res://screens/game_screen/levels/"+level))

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
	var home : bool = game_mode.respawn_from_home
	
	if home and ship.info_player.lives != 0:
		respawn_from_home(ship, ship.spawner)
	
	for_good = for_good or home
	
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
	deathflash.big = for_good # big explosion if the ship is totally destroyed
	deathflash.species = ship.species
	deathflash.position = ship.position
	$Battlefield.call_deferred("add_child", deathflash)
	
	if not for_good:
		$Battlefield.call_deferred("add_child", ship.dead_ship_instance)
		
		ship.dead_ship_instance.apply_central_impulse(ship.linear_velocity*0.3)
		ship.dead_ship_instance.apply_torque_impulse((1000+ship.linear_velocity.length())*2)
	
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
#	if game_mode.id == 'rocket_crown' or game_mode.id == 'rocket_queen_of_the_hive':
#		#respawn_timeout = 0.75
#		var cargo = ship.get_cargo()
#		if cargo.has_holdable():
#			respawn_timeout = 1.25 + 0.5*global.the_game.get_number_of_players()
#	#elif conquest_mode.enabled:
#	#	respawn_timeout = 0.75
#	#elif game_mode.name == "GoalPortal":
#	#	respawn_timeout = 0.75
#
#	if game_mode.id == 'diamond_warfare':
#		respawn_timeout = 3.5
	
	yield(get_tree().create_timer(respawn_timeout), "timeout")
	
	if not global.is_match_running():
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
	set_process_unhandled_input(false)
	for child in $Managers.get_children():
		if child is ModeManager:
			child.enabled = false
	camera.stop_and_zoomout(compute_arena_size())
	$GameOverAnim.play('Game Over')
	yield($GameOverAnim, "animation_finished") # wait for animation and UI redraw (esp. bars)
	set_time_scale(1)
	get_tree().paused = true
	var game_over = gameover_scene.instance()
	#game_over.connect("pressed_continue", self, "_on_Continue_session")
	game_over.connect("show_arena", self, "_on_Show_Arena")
	game_over.connect("hide_arena", self, "_on_hide_Arena")
	canvas.add_child(game_over)

func _on_continue_after_game_over(_session_over):
	if standalone:
		get_tree().reload_current_scene()
	
func _on_Show_Arena():
	$Battlefield/Background.modulate = Color(1,1,1,1)
	$Battlefield/Middleground.modulate=Color(1,1,1,1)
	$BackgroundLayer.get_child(0).modulate=Color(1,1,1,1)

func _on_hide_arena():
	$Battlefield/Background.modulate=Color(0.33,0.33,0.33,1)
	$Battlefield/Middleground.modulate=Color(0.33,0.33,0.33,1)
	$BackgroundLayer.get_child(0).modulate=Color(0.33,0.33,0.33,1)
	
const ship_scene = preload("res://actors/battlers/Ship.tscn")
const trail_scene = preload("res://actors/battlers/TrailNode.tscn")

onready var focus_in_camera = $Battlefield/Overlay/ElementInCamera

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
	ship = ship_scene.instance()
	
	var brain : Brain
	if player.is_cpu():
		brain = cpu_brain_scene.instance()
	else:
		brain = player_brain_scene.instance()
		brain.set_controls(player.controls)
	brain.set_controllee(ship)
	ship.set_brain(brain)
	
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
	
	ship.set_start_invincible(game_mode.start_invincible)
	
	yield(player, "entered_battlefield")
	
	$Battlefield.add_child(ship)
	
	create_trail(ship)
	yield(get_tree(), "idle_frame") # FIXME this is needed for set_bomb_type
	register_ship(ship)
	
	# connect collect signals to enable powerup collection at start
	ship.connect("body_entered", collect_manager, "ship_sth_entered", [ship])
	ship.connect("near_area_entered", collect_manager, "ship_sth_entered")
	ship.connect('thrusters_on', self, '_on_ship_thrusters_on', [ship]) # this is for snake powerup to work
	
	ship.recheck_colliding()
	emit_signal('ship_spawned', ship)
	
	if force_intro:
		ship.intro()
	
	# Check on gears
	ship.set_bombs_enabled(game_mode.shoot_bombs)
	ship.set_default_bomb_type(game_mode.bomb_type)
	ship.set_default_bomb_type(game_mode.bomb_type)
	ship.set_ammo(game_mode.starting_ammo)
	ship.set_reload_time(game_mode.reload_time)
	ship.set_lives(game_mode.starting_lives)
	ship.set_max_health(game_mode.starting_health)
	ship.set_auto_thrust(game_mode.auto_thrust)
	
	# connect signals
	ship.connect("dead", self, "ship_just_died")
	ship.connect("frozen", self, "_on_sth_just_froze")
	ship.connect("spawn_bomb", self, "spawn_bomb", [ship])
	ship.connect("near_area_entered", combat_manager, "_on_ship_collided")
	ship.connect("body_entered", combat_manager, "_on_ship_collided", [ship])
	ship.connect("body_entered", environments_manager, "_on_sth_entered", [ship])
	ship.connect("near_area_entered", environments_manager, "_on_sth_entered")
	ship.connect("near_area_exited", environments_manager, "_on_sth_exited")
	ship.connect("detection", pursue_manager, "_on_ship_detected")
	ship.connect("dead", kill_mode, "_on_sth_killed")
	ship.connect("dead", last_man_mode, "_on_sth_killed")
	#ship.connect("dead", combat_manager, "_on_sth_killed")
	ship.connect("dead", collect_manager, "_on_ship_killed")
	ship.connect("near_area_entered", conquest_manager, "_on_ship_collided")
	ship.connect("fallen", self, "_on_ship_fallen")
	
	crown_mode.connect('show_msg', ship, "update_score")
	return ship
	
const bomb_scene = preload('res://actors/weapons/Bomb.tscn')
const mine_scene = preload('res://combat/collectables/RemoteBomb.tscn')
const wave_scene = preload('res://actors/weapons/ShockWave.tscn')
func spawn_bomb(type, symbol, pos, impulse, ship, size=1):
	var bomb
	if type == GameMode.BOMB_TYPE.mine:
		bomb = mine_scene.instance()
		bomb.set_owner_ship(ship)
		bomb.position = ship.global_position
		bomb.set_lifetime(max(1.0, impulse.length()/4000))
		bomb.set_radius(max(600.0, impulse.length()/7))
		bomb.apply_central_impulse(impulse*1.2)
	elif type == GameMode.BOMB_TYPE.wave:
		bomb = wave_scene.instance()
		bomb.set_owner_ship(ship)
		bomb.position = ship.global_position
		bomb.rotation = ship.global_rotation+PI
		bomb.growth = max(300, impulse.length()/10)
		bomb.speed = 1500 - impulse.length()/6
		bomb.lifetime = max(0.6, impulse.length()/4000)
		bomb.angle = 2*PI/3 + impulse.length()/3000
	else:
		bomb = bomb_scene.instance()
		bomb.initialize(type, pos, impulse, ship, size)
		if symbol:
			bomb.symbol = symbol
		
		bomb.connect("near_area_entered", combat_manager, "bomb_near_area_entered")
		bomb.connect("near_area_entered", environments_manager, "_on_sth_entered")
		bomb.connect("near_area_exited", environments_manager, "_on_sth_exited")
		bomb.connect("detonate", self, "bomb_detonated", [bomb])
	
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
		
	if collectee.has_method('on_collected_by'):
		collectee.on_collected_by(collector)
		
	if collector.has_method('on_collect'):
		collector.on_collect(collectee)
		
	collectee.get_parent().call_deferred('remove_child', collectee)
	# collisions do not work as expected without defer
		
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
		

signal wave_ready

func dramatic_spawn(to_be_spawned: ElementSpawnerGroup , wait_time=1):
	if wait_time:
		focus_in_camera.move(to_be_spawned.position, wait_time)
		yield(focus_in_camera, "completed")
	to_be_spawned.spawn()
	Events.emit_signal("spawned", to_be_spawned)
	

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
	respawn_from_home(ship, spawner)
	
func respawn_from_home(ship, spawner):
	var respawn_timeout = 1.0
	if game_mode.id == 'skull_collector':
		respawn_timeout = 0.5
	
	ship.trail.destroy()
	if ship.alive:
		ship.die(null, true) # die for good
	yield(get_tree().create_timer(respawn_timeout), "timeout")
	spawner.appears()
	spawn_ship(spawner, true) # force intro
	
func connect_killable(killable):
	killable.connect('killed', kill_mode, '_on_sth_killed')
	#killable.connect('killed', combat_manager, '_on_sth_killed')
	
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

func _on_goal_done(player, goal, pos, points=1):
	global.the_match.add_score_to_team(player.team, points)
	show_msg(player.species, points, pos)
	
var Ripple = load('res://actors/weapons/Ripple.tscn')
func show_ripple(pos, size=1):
	var ripple = Ripple.instance()
	ripple.position = pos
	ripple.scale = Vector2(size, size)
	$Battlefield.call_deferred("add_child", ripple)
	
# players -> ships register
var player_ships := {}

func register_ship(ship : Ship) -> void:
	player_ships[ship.get_player().id] = ship
	
func unregister_ship(ship : Ship) -> void:
	player_ships.erase(ship.get_player().id)
	
func get_ship_from_player(player : InfoPlayer) -> Ship:
	return player_ships[player.id]
	
func get_ship_from_player_id(player_id : String) -> Ship:
	return player_ships[player_id]
	
func is_ship_valid(ship : Ship) -> bool:
	return ship in player_ships.values()
	
func player_has_valid_ship(player : InfoPlayer) -> bool:
	return player.id in player_ships
	
func get_all_valid_ships() -> Array:
	return player_ships.values()
	
func get_all_ships_in_team(team) -> Array:
	var result = []
	for ship in player_ships.values():
		if ship.get_team() == team:
			result.append(ship)
	return result

func _on_PowerUp_collected():
	pass # Replace with function body.

# NAVIGATION
var queued_navzones_update := false
func _on_navigation_zone_changed(zone):
	if queued_navzones_update:
		return
	queued_navzones_update = true
	print('a navigation zone has changed... about to update navigation')
	# very pessimistic
	yield(get_tree(), "idle_frame")
	call_deferred('update_navigation_zones')
	
func update_navigation_zones():
	# delete all navigation nodes already present, if any
	for child in $"%Navigation".get_children():
		child.free()
		
	# prepare zone for each layer
	var navigation_polygons = {
		'default': NavigationPolygon.new(),
		'holder': NavigationPolygon.new()
	}
	for zone_t in traits.get_all('NavigationZone'):
		var polygon = zone_t.get_polygon()
		var layers = zone_t.get_layers()
		var offset
		match zone_t.get_offset_type():
			'none':
				offset = 0
			'inset':
				offset = -100
			'outset':
				offset = 100
		var result = Geometry.offset_polygon_2d(polygon, offset)
		for resulting_polygon in result:
			for layer in layers:
				navigation_polygons[layer].add_outline(resulting_polygon)
	
	for layer in navigation_polygons.keys():
		var navpoly = navigation_polygons[layer]
		navpoly.make_polygons_from_outlines()
		var navpoly_instance = NavigationPolygonInstance.new()
		navpoly_instance.set_navigation_polygon(navpoly)
		var bitmask
		match(layer):
			'default':
				bitmask = 1
			'holder':
				bitmask = 2
		navpoly_instance.set_navigation_layers(bitmask)
		$"%Navigation".add_child(navpoly_instance)
	
	queued_navzones_update = false
	
