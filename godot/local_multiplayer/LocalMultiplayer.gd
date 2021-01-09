extends Node

onready var selection_screen = $SelectionScreen

var session_scores : TheSession

const combat_scene = "res://combat/levels/"
const level_selection_scene = preload("res://local_multiplayer/LevelSelection.tscn")
export var map_scene: PackedScene

var sports = {} # {sport.name : Resource}
var sports_array = []
var all_sports = [
	# preload("res://map/planets/sets/core.tres")
	]
	
var first_time = true
var all_species = []
onready var parallax = $ParallaxBackground
var map
var combat

# dictionary of InfoPlayer of players that will actually play
var players : Dictionary # of InfoPlayer

signal updated

var campaign_mode : bool = false # Needed for instancing MAP

func reset():
	
	for key in players:
		var player = players[key]
		player.reset()
	campaign_mode = global.campaign_mode
	global.new_session(players)
	
	
func _ready():
	for species in TheUnlocker.get_unlocked():
		all_species.append(species)
		
	session_scores = TheSession.new()
	session_scores.set_players(players)

	campaign_mode = global.campaign_mode
	players = {}

	selection_screen.initialize()
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
var played_levels : Array
var played_levels_scene: PackedScene
var levels : Array

func combat(selected_players: Array, fight_mode : String):
	"""
	@param: selected_players : Array[PlayerSelection] - Selected species from selection screen
	It will transform the selected_players array in a dictionary of info players
	"""
	var i = 0
	
	# we need to reset players dictionary
	players = {}
	sports_array = []
	played_levels = []
	levels = []
	all_sports = []
	var num_players : int = len(selected_players)
	
	global.send_stats("design", {"event_id":"selection:num_players", "value": num_players})

	i = 1
	for player in selected_players:
		players[player.id] = player.info
		i += 1
	
	session_scores.players = players

	# Statistics
	for player_id in players:
		var info = players[player_id]
		global.send_stats("design", {"event_id": "selection:species:{key}".format({"key": info.species_name})})
		global.send_stats("design", {"event_id": "selection:players:{id}:{key}".format({"key": info.controls, "id": info.id})})
		
	# PLANET SELECTION
	remove_child(selection_screen)
	remove_child(parallax)
	var num_CPUs = 0 if len(players) > 1 else 1
	if not campaign_mode:
		map = map_scene.instance()
		map.initialize(players, all_sports, session_scores.settings)
		add_child(map)
		yield(map, "done")
		yield(get_tree(), "idle_frame")
		all_sports = map.selected_sports
		for sport in all_sports:
			global.send_stats("design", {"event_id": "selection:sports:{sport_name}".format({"sport_name": sport.name})})
		num_CPUs = map.cpu
		global.send_stats("design", {"event_id": "selection:cpu:{num_cpu}:players:{num_players}".format({"num_cpu": str(num_CPUs), "num_players": str(num_players)})})
		session_scores.settings = map.settings
		if map.back:
			map.queue_free()
			add_child(parallax)
			add_child(selection_screen)
			selection_screen.reset()
			return
		
	
	# if fight_mode == 'solo':
	add_cpu(num_CPUs)
	session_scores.selected_sports = all_sports
	
	for sport in all_sports:
		
		# issue #428 . Handle mutator
		session_scores.set_mutators(sport.mutators)
		
		sports[sport.name] = sport
		sports_array.append(sport.name)
		for level in sport.get_levels(num_players):
			# Deduplication issue #405
			if not level in levels:
				levels.append(level)
	
	sports_array.shuffle() # shuffle the planets at start
	levels.shuffle()
	
	first_time = true
	played_levels = []
	played_levels_scene = null
	
	next_level(global.demo)
	GameAnalytics.submit_events()
	global.new_session(players)

func next_level(demo=false):
	if not map.is_inside_tree():
		add_child(map)
	map.check()
	yield(map, "check_completed")
	var this_game = choose_next_level()
	map.choose_level(this_game)
	yield(map, "chose_level")
	remove_child(map)
	if not parallax.is_inside_tree():
		add_child(parallax)
	start_level(this_game, demo)
	
func choose_next_level(demo=false):
	""" Choose next level from the array of selected. If over, choose randomly """
	var last_sport = null
	if len(played_levels) > 0:
		last_sport = played_levels.back()
	var num_players = len(players)
	
	if len(played_levels) >= len(sports_array) or demo:
		played_levels = []
		sports_array.shuffle()
	
	# we are going to play the following games:
	var new_sport = sports_array.pop_back()
	sports_array.push_front(new_sport)

	while last_sport == new_sport:
		new_sport = sports_array.pop_back()
		sports_array.push_front(new_sport)
		if len(sports_array)<= 1:
			break
	
	# let's make sure that it is not the same of the previous one.
	current_level = levels.pop_back()
	levels.push_front(current_level)
	played_levels_scene=current_level
	played_levels.append(new_sport)
	return current_level.instance()
	
func start_level(_level, demo = false):
	
	if self.first_time:
		# TUTORIAL
		var tut = preload("res://special_scenes/Tutorial.tscn").instance()
		add_child(tut)
		yield(tut, "over")
		# END TUTORIAL
		self.first_time = false
	
	combat = _level
	
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
	
	start_level(played_levels_scene.instance())

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
	var missing_species = TheUnlocker.get_ordered_species()
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
		
