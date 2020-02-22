extends Node

onready var selection_screen = $SelectionScreen

var session_scores : SessionScores

const combat_scene = "res://combat/levels/"
const level_selection_scene = preload("res://local_multiplayer/LevelSelection.tscn")
export var map_scene: PackedScene
# temporary for all levels
var all_planets = [
	preload("res://map/planets/SoloCrown.tres"),
	preload("res://map/planets/SoloSnatch.tres"),
	preload("res://map/planets/SoloFlag.tres"),
	preload("res://map/planets/SoloDeath.tres"),
	preload("res://map/planets/Pentagoal.tres"),
	# preload("res://map/planets/EelectronPlanet.tres"),
	# preload("res://map/planets/MinefieldDeathmatch.tres")
	]
	
var all_species = [
	preload('res://selection/characters/mantiacs_1.tres'),
	preload('res://selection/characters/robolords_1.tres'),
	preload('res://selection/characters/toriels_1.tres'),
	preload('res://selection/characters/trixens_1.tres'),
]
onready var parallax = $ParallaxBackground

var combat

# dictionary of InfoPlayer of players that will actually play
var players : Dictionary # of InfoPlayer

signal updated

var campaign_mode : bool = false

func reset():
	session_scores = SessionScores.new()
	session_scores.players = players
	for key in players:
		var player = players[key]
		player.reset()
	campaign_mode = global.campaign_mode
	
func _ready():
	session_scores = SessionScores.new()
	session_scores.players = players

	campaign_mode = global.campaign_mode
	players = {}

	selection_screen.initialize(global.get_unlocked())
	selection_screen.connect("fight", self, "combat")
	selection_screen.connect("back", self, "back")
	global.local_multiplayer = self

func _exit_tree():
	global.local_multiplayer = null

func back():
	# This goes back to the previous scene
	# TODO: maybe this is not the right way
	get_tree().change_scene(global.from_scene)
	
var current_level
var levels : Array
var played_levels : Array

func combat(selected_players: Array, fight_mode : String):
	"""
	@param: selected_players : Array[Species] - Selected species from selection screen
	It will transform the selected_players array in a dictionary of info players
	"""
	
	# we need to reset players dictionary
	players = {}
	var num_players : int = len(selected_players)
	global.send_stats("design", {"event_id":"selection:players:num_players", "value": num_players})

	var i = 1
	for player in selected_players:
		players[player.id] = player.info
		i += 1
	
	session_scores.players = players

	# Statistics
	for player_id in players:
		var info = players[player_id]
		global.send_stats("design", {"event_id": "selection:species:{key}:{id}".format({"key": info.species_name, "id": info.id})})
		global.send_stats("design", {"event_id": "selection:players:{key}:{id}".format({"key": info.controls, "id": info.id})})


	# PLANET SELECTION
	remove_child(selection_screen)
	remove_child(parallax)
	var num_CPUs = 0 if len(players) > 1 else 1
	if not campaign_mode:
		var map = map_scene.instance()
		map.initialize(players, all_planets)
		
		add_child(map)
		yield(map, "done")
		yield(get_tree(), "idle_frame")
		all_planets = map.selected_sports
		for sport in all_planets:
			global.send_stats("design", {"event_id": "combat:sport:{sport_name}".format({"sport_name": sport.name})})
		
		num_CPUs = map.cpu
		session_scores.settings = map.settings
		if map.back:
			map.queue_free()
			add_child(parallax)
			add_child(selection_screen)
			selection_screen.reset()
			return
		
		map.queue_free()
	
	# if fight_mode == 'solo':
	add_cpu(num_CPUs)
		
	session_scores.selected_sports = all_planets
	
	
	all_planets.shuffle() # shuffle the planets at start
	# for planet in all_planets:
	#	planet.shuffle_levels(len(players))
	
	add_child(parallax)
	
	# TUTORIAL
	var tut = preload("res://special_scenes/Tutorial.tscn").instance()
	add_child(tut)
	yield(tut, "over")
	# END TUTORIAL
	next_level()
	
	# TEST: send the queue
	GameAnalytics.submit_events()

func next_level(demo=false):
	""" Choose next level from the array of selected. If over, choose randomly """
	var last_planet = played_levels.back()
	var num_players = len(players)
	
	if len(played_levels) >= len(all_planets) or demo:
		played_levels = []
		levels = []
		all_planets.shuffle()

	# FIXME it seems that selecting three planets does not work as expected
	var new_planet = all_planets.pop_back()
	all_planets.push_front(new_planet)
	if last_planet == new_planet:
		new_planet = all_planets.pop_back()
		all_planets.push_front(new_planet)
	levels.append(new_planet.fetch_level(num_players))
	
	# let's make sure that it is not the same of the previous one.
	current_level = levels.back()

	# skip if we just played it
	start_level(current_level, demo)
	played_levels.append(new_planet)
	
func start_level(_level, demo = false):
	combat = _level
	combat.initialize(session_scores)
	combat.connect("restart", self, "_on_Pause_restart", [combat])
	combat.connect("rematch", self, "_on_GameOver_rematch", [combat])
	combat.connect("back_to_menu", self, "_back_to_menu", [combat])
	connect("updated", combat, "hud_update")
	
	for child in get_children():
		if child is Arena:
			child.queue_free()
			yield(child, 'tree_exited')
	combat.demo = demo

	add_child(combat)
	yield(combat, "ready")
	
	
func _on_GameOver_rematch(node):
	node.queue_free()
	get_tree().paused = false
	# combat.queue_free()

	# yield(get_tree().create_timer(1), "timeout")
	next_level()
	
func _on_Pause_restart(_combat):
	var same_level = played_levels.back()
	_combat.queue_free()
	get_tree().paused = false
	
	start_level(same_level.fetch_level(len(players)))

func _back_to_menu(node):
	reset()
	node.queue_free()
	combat.queue_free()
	get_tree().paused = false
	add_child(selection_screen)
	selection_screen.reset()
	if global.demo:
		selection_screen.deselect()
	
func _on_Pause_back_to_menu(_combat):
	_combat.queue_free()
	get_tree().paused = false
	add_child(selection_screen)


func start_demo():
	var demo_players = []
	var player_rand = max(2, (randi() % len(all_species))+1)
	players = {}
	for i in range(player_rand):
		var other_species = all_species[i]
		var info_player = InfoPlayer.new()
		info_player.id = 'cpu'
		info_player.species = other_species.species_name
		info_player.cpu = true
		info_player.species_template = other_species
		players["cpu{id}".format({"id": i})] = info_player
	remove_child(selection_screen)
	next_level(true)
	
func add_cpu(how_many: int):
	var missing_species = all_species
	for key in players:
		var player = players[key]
		var this_species_name = player.species.species_name
		var i = 0
		for species in missing_species:
			if this_species_name == species.species_name:
				break
			i += 1
		missing_species.remove(i)
	
	var max_cpu = min(how_many, len(missing_species))
	max_cpu = min(max_cpu, global.MAX_PLAYERS)
	for i in range(max_cpu):
		var cpu_species = missing_species[i]
		var info_player = InfoPlayer.new()
		var id_player = 'cpu'+str(i)
		info_player.id = id_player
		info_player.cpu = true
		info_player.species = cpu_species
		players[id_player] = info_player
		