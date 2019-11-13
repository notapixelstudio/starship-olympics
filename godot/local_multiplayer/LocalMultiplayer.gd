extends Node

onready var selection_screen = $SelectionScreen

const combat_scene = "res://combat/levels/"
const level_selection_scene = preload("res://local_multiplayer/LevelSelection.tscn")
export var map_scene: PackedScene
# temporary for all levels
var all_planets = [
	preload("res://map/planets/SoloCrown.tres"),
	preload("res://map/planets/SoloSnatch.tres"),
	preload("res://map/planets/SoloFlag.tres"),
	preload("res://map/planets/SoloDeath.tres"),
	# preload("res://map/planets/EelectronPlanet.tres"),
	# preload("res://map/planets/MinefieldDeathmatch.tres")
	]
	
var all_species = [
	[preload('res://selection/characters/mantiacs_1.tres'), preload('res://selection/characters/mantiacs_2.tres')],
	[preload('res://selection/characters/robolords_1.tres'), preload('res://selection/characters/robolords_2.tres')]
]
onready var parallax = $ParallaxBackground

var combat

# dictionary of InfoPlayer of players that will actually play
var players : Dictionary

signal updated

func _unhandled_input(event):
	if event.is_action_pressed("force_pause"):
		get_tree().reload_current_scene()

func from_species_to_info_player(selection_species: Species) -> InfoPlayer:
	var info_player = InfoPlayer.new()
	info_player.id = selection_species.name
	info_player.species = selection_species.species_template.species_name
	info_player.controls = selection_species.controls
	info_player.species_template = selection_species.species_template
	info_player.team = selection_species.is_team
	print_debug("Is that a teammate")
	print_debug(info_player.team)
	return info_player
	
func _ready():
	players = {}
	selection_screen.initialize(global.get_unlocked())
	selection_screen.connect("fight", self, "combat")
	selection_screen.connect("back", self, "back")

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
	# TEST: analytics for selection
	
	# we need to reset players dictionary

	players = {}
	var num_players : int = len(selected_players)
	global.send_stats("design", {"event_id":"selection:num_players", "value": num_players})

	var i = 1
	for player in selected_players:
		assert(player is Species)
		var player_info : InfoPlayer = from_species_to_info_player(player)
		player_info.id = player.id
		players[player.id] = player_info
		i += 1
	
	# Statistics
	for player_id in players:
		var info = players[player_id]
		global.send_stats("design", {"event_id": "selection:{key}:{id}".format({"key": info.species, "id": info.id})})
		global.send_stats("design", {"event_id": "selection:{key}:{id}".format({"key": info.controls, "id": info.id})})
	
	if fight_mode == 'solo' or fight_mode == 'co-op':
		var other_species
		if selected_players[0].species_template.species_name != all_species[0][0].species_name:
			other_species = all_species[0]
		else:
			other_species = all_species[1]

		var info_player = InfoPlayer.new()
		info_player.id = 'cpu'
		info_player.species = other_species[0].species_name
		info_player.cpu = true
		info_player.species_template = other_species[0]
		
		players['cpu'] = info_player
		
		if fight_mode == 'co-op':
			info_player.team = true
			
			var info_player2 = InfoPlayer.new()
			info_player2.id = 'cpu'
			info_player2.team = true
			info_player2.species = other_species[1].species_name
			info_player2.cpu = true
			info_player2.species_template = other_species[1]
			players['cpu2'] = info_player2
			
	# LEVEL SELECTION
	#var level_selection = level_selection_scene.instance()
	#level_selection.initialize(str(num_players), players)
	#add_child(level_selection)
	#yield(level_selection, "arena_selected")
	#if level_selection.back:
	#	level_selection.queue_free()
	#	return
	#current_level = level_selection.current_level
	
	# PLANET SELECTION
	remove_child(selection_screen)
	remove_child(parallax)
	var map = map_scene.instance()
	map.initialize(players)
	"""
	add_child(map)
	yield(map, "done")
	yield(get_tree(), "idle_frame")
	if map.back:
		map.queue_free()
		add_child(parallax)
		add_child(selection_screen)
		return
	"""

	all_planets.shuffle() # shuffle the planets at start
	for planet in all_planets:
		planet.shuffle_levels(num_players)

	# logic to get the correct levels
	# TODO: depends if the cursor can select multiple planets
	levels = []
	played_levels = []
	var count = 0
	for planet in map.current_planets:
		print("never here")
		planet.shuffle_levels(num_players)
		var arena = planet.fetch_level(num_players)
		# avoid duplicate
		var last_planet = levels.back()
		if not last_planet or planet != last_planet:
			levels.append(arena)
			count += 1
	
	levels.shuffle()
	
	#level_selection.queue_free()
	map.queue_free()
	add_child(parallax)
	
	next_level()
	
	# TEST: send the queue
	GameAnalytics.submit_events()

func next_level():
	""" Choose next level from the array of selected. If over, choose randomly """
	var last_planet = played_levels.back()
	var num_players = len(players)
	
	if len(played_levels) >= len(all_planets):
		played_levels = []
		levels = []
		all_planets.shuffle()

	
	var new_planet = all_planets.pop_back()
	all_planets.push_front(new_planet)
	if last_planet == new_planet:
		new_planet = all_planets.pop_back()
		all_planets.push_front(new_planet)
	levels.append(new_planet.fetch_level(num_players))
	
	# let's make sure that it is not the same of the previous one.
	current_level = levels.back()
	print_debug("last planet was, ", last_planet, " now is ", new_planet)
	print_debug("next level will be ", num_players, current_level.planet_name)
	# skip if we just played it
	start_level(current_level)
	played_levels.append(new_planet)
	
func start_level(_level):
	combat = _level
	print_debug(players)
	combat.initialize(players)
	combat.connect("restart", self, "_on_Pause_restart", [combat])
	combat.connect("rematch", self, "_on_GameOver_rematch", [combat])
	combat.connect("back_to_menu", self, "_back_to_menu", [combat])
	connect("updated", combat, "hud_update")
	
	add_child(combat)
	
func from_info_to_spawner(player_info):
	var spawner = PlayerSpawner.new()
	spawner.controls = player_info.controls 
	spawner.species_template = player_info.species_template
	spawner.name = player_info.id
	spawner.info_player = player_info
	return spawner
	
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
	node.queue_free()
	combat.queue_free()
	get_tree().paused = false
	add_child(selection_screen)
	if global.demo:
		selection_screen.deselect()
	
func _on_Pause_back_to_menu(_combat):
	_combat.queue_free()
	get_tree().paused = false
	add_child(selection_screen)
