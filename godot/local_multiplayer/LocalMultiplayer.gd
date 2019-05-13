extends Node

onready var selection_screen = $SelectionScreen

const combat_scene = "res://combat/levels/"
const level_selection_scene = preload("res://local_multiplayer/LevelSelection.tscn")
export var map_scene: PackedScene

onready var parallax = $ParallaxBackground

var combat = null
var selected_level
# dictionary of InfoPlayer of players that will actually play
var players : Dictionary

signal updated

func from_species_to_info_player(selection_species: Species) -> InfoPlayer:
	var info_player = InfoPlayer.new()
	info_player.id = selection_species.name
	info_player.species = selection_species.species_template.species_name
	info_player.controls = selection_species.controls
	info_player.species_template = selection_species.species_template
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
	
var current_level : Dictionary
var levels : Array
var played_levels : Array

func combat(selected_players: Array):
	"""
	@param: selected_players : Array[Species] - Selected species from selection screen
	It will transform the selected_players array in a dictionary of info players
	"""
	# TEST: analytics for selection
	
	# we need to reset players dictionary

	players = {}
	var num_players : int = len(selected_players)

	GameAnalytics.add_to_event_queue(GameAnalytics.get_test_design_event("selection:num_players", num_players))

	var i = 1
	for player in selected_players:
		assert(player is Species)
		var player_info : InfoPlayer = from_species_to_info_player(player)
		players[player.id] = player_info
		# Prepare GameAnalytics event to send
		GameAnalytics.add_to_event_queue(GameAnalytics.get_test_design_event("selection:species:" + player.species_template.species_name, i))
		i += 1
	
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
	add_child(map)
	yield(map, "done")
	yield(get_tree(), "idle_frame")
	if map.back:
		map.queue_free()
		add_child(parallax)
		add_child(selection_screen)
		return
		
	# logic to get the correct levels
	levels = []
	played_levels = []
	var MAX_LEVELS: float = 8.0
	var how_many_levels_from_each_planet = ceil(MAX_LEVELS / len(map.current_planets))
	
	for planet in map.current_planets:
		for i in range(how_many_levels_from_each_planet):
			levels.append({"planet": planet, "level":planet.fetch_level(num_players)})
	
	#level_selection.queue_free()
	map.queue_free()
	add_child(parallax)
	
	next_level()
	
	# TEST: send the queue
	GameAnalytics.submit_events()

func next_level():
	if len(played_levels) >= len(levels):
		add_child(selection_screen)
		return
		
	current_level = levels[len(played_levels)]
	played_levels.append(current_level)
	
	start_level(current_level)
	
func start_level(_level):
	selected_level = _level
	var planet: Planet = selected_level["planet"]
	combat = selected_level["level"].instance()
	combat.planet_name = planet.name
	combat.game_mode = planet.game_mode
	combat.initialize(players)
	combat.connect("restart", self, "_on_Pause_restart", [combat])
	combat.connect("rematch", self, "_on_GameOver_rematch", [combat])
	combat.connect("back_to_menu", self, "_back_to_menu", [combat])
	connect("updated", combat, "hud_update")
	yield(get_tree().create_timer(0.5), "timeout")
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
	combat.queue_free()
	next_level()
	
func _on_Pause_restart(_combat):
	_combat.queue_free()
	get_tree().paused = false
	start_level(current_level)

func _back_to_menu(node):
	print("RESTARTO")
	node.queue_free()
	combat.queue_free()
	get_tree().paused = false
	add_child(selection_screen)
	
func _on_Pause_back_to_menu(_combat):
	_combat.queue_free()
	get_tree().paused = false
	add_child(selection_screen)