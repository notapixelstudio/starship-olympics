extends Node

onready var selection_screen = $SelectionScreen

const combat_scene = "res://combat/levels/"
export var map_scene: PackedScene

var games = {}  # {sport.name : Resource}

var first_time = true # In order to show the TUTORIAL
var all_species = []
onready var parallax = $ParallaxBackground
var map: Map
var combat

# dictionary of InfoPlayer of players that will actually play
var players: Dictionary  # of InfoPlayer

signal updated


class PlayerArena:
	# This class will store an Arena and the player who chose it
	var player_id: String
	var this_game: Arena

func reset():
	"""
	This function will reset the session
	"""
	global.new_session(players)
	for player in players.values():
		player.reset()

func _init():
	reset()

func _ready():
	for species in TheUnlocker.get_unlocked():
		all_species.append(species)
	
	players = {}
	selection_screen.initialize()
	selection_screen.connect("fight", self, "start_fight")
	selection_screen.connect("back", self, "back")
	global.local_multiplayer = self


func _exit_tree():
	global.local_multiplayer = null


func back():
	# This goes back to the previous scene
	# TODO: maybe this is not the right way
	return get_tree().change_scene(global.from_scene)





func start_fight(selected_players: Array, fight_mode: String):
	"""
	Parameters:
		----------
		selected_players : Array[InfoPlayer]
	After selection will handle the map and then the list of games
	@param: selected_players : Array[PlayerSelection] - Selected species from selection screen
	It will transform the selected_players array in a dictionary of info players
	"""
	var i = 0
	
	# TODO: maybe reset function
	# we need to reset players dictionary
	players = {}
	var num_players: int = len(selected_players)

	global.send_stats("design", {"event_id": "selection:num_players", "value": num_players})

	# SET the players dictionary
	i = 1
	for player in selected_players:
		assert(player is InfoPlayer)
		players[player.id] = player
		i += 1

	global.new_session(players)

	go_to_map()

func return_to_selection_screen():
	map.queue_free()
	add_child(parallax)
	add_child(selection_screen)
	selection_screen.reset()
	return
	
var players_sequence : Array = []
var selected_sets_by_player : Dictionary = {}
var minigame_pools : Dictionary = {}
var last_minigame = null

func continue_to_fight(map_selection: Dictionary) -> void:
	"""
	After map selection we need to set the structure for the selection of sports.
	Will go back to selection screen or 
	"""
	var players_selection = map_selection.get("players_selection")
	var sets = map_selection.get("sets")
	var settings = map_selection.get("settings", {})
	
	var num_CPUs = 0 if len(players) > 1 else 1
	add_cpu(num_CPUs)
	
	global.session.setup_selected_sets(sets)
	
	players_sequence = []
	minigame_pools = {}
	selected_sets_by_player = {}
	last_minigame = null
	
	for player in players_selection:
		var set : Planet = players_selection[player]
		selected_sets_by_player[player] = set
		players_sequence.append(player)
		minigame_pools[set.name] = set.get_minigames()
		assert(len(minigame_pools[set.name]) > 0)
		minigame_pools[set.name].shuffle()
	
	players_sequence.shuffle()
	
	first_time = true
	
	global.new_session(players)
	next_level(global.demo)
	GameAnalytics.submit_events()
	
	return
	
func go_to_map():
	# map initialization
	remove_child(selection_screen)
	remove_child(parallax)
	var num_CPUs = 0 if len(players) > 1 else 1
	map = map_scene.instance()
	map.initialize(players)
	add_child(map)
	map.connect("back", self, "return_to_selection_screen")
	map.connect("done", self, "continue_to_fight")

func next_level(demo = false):
	"""
	This function will select the next minigame, passing from the map
	"""
	
	if not map.is_inside_tree():
		add_child(map)
	
	var player_arena = choose_next_level()
	var this_game = player_arena.this_game
	map.choose_level(this_game, player_arena.player_id)
	yield(map, "chose_level")
	$TransitionScreen.transition()
	yield($TransitionScreen, "transitioned")
	remove_child(map)
	if not parallax.is_inside_tree():
		add_child(parallax)
	start_level(this_game, demo)

func get_next_minigame(set):
	# replenish pool if empty
	if len(minigame_pools[set.name]) == 0:
		minigame_pools[set.name] = set.get_minigames()
		minigame_pools[set.name].shuffle()
		
	return minigame_pools[set.name].pop_back()

func choose_next_level(demo = false) -> PlayerArena : #{String: Arena}
	""" Choose next level rotating sets and avoiding back to back duplicates minigames. """
	var player = players_sequence.pop_back()
	players_sequence.push_front(player)
	var next_set = selected_sets_by_player[player]
	
	var next_minigame = get_next_minigame(next_set)
	
	# WARNING this is not a while because it's better to repeat a level than to
	# hang the game (in case a set contains all copies of the same levels)
	if next_minigame == last_minigame: # best effort deduplication
		next_minigame = get_next_minigame(next_set)
	
	last_minigame = next_minigame
	var player_arena : PlayerArena = PlayerArena.new()
	player_arena.player_id = player
	print(next_minigame.get_id())
	player_arena.this_game = next_minigame.get_level(len(players)).instance()
	return player_arena

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
	combat.connect("skip", self, "_on_continue_session", [combat])
	combat.connect("continue_session", self, "_on_continue_session", [combat])
	combat.connect("back_to_menu", self, "_back_to_menu", [combat])
	connect("updated", combat, "hud_update")

	for child in get_children():
		if child is Arena:
			child.queue_free()
			yield(child, 'tree_exited')
	combat.demo = demo

	add_child(combat)


func _on_continue_session(combat_scene, session_over = false):
	"""
	This callback will be called after the gameover.
	Will handle if there is something to unlock
	"""
	combat_scene.queue_free()
	get_tree().paused = false
	if session_over:
		end_session()
	else:
		next_level()


func end_session():
	"""
	This will handle the end of the session (Will unlock 
	if there is something to unlock or will go back to selection)
	"""
	#reset()
	combat.queue_free()
	get_tree().paused = false
	if TheUnlocker.what_to_unlock():
		if not map.is_inside_tree():
			add_child(map)
		map.connect("unlocked_done", self, "back_to_selection_screen")
	else:
		back_to_selection_screen()
		
func back_to_selection_screen():
	remove_child(map)
	if not parallax.is_inside_tree():
		add_child(parallax)
		add_child(selection_screen)
	selection_screen.reset()
	if global.demo:
		selection_screen.deselect()
	

func _on_Pause_restart(_combat):
	var same_level = last_minigame.get_level(len(players)).instance()
	_combat.queue_free()
	get_tree().paused = false

	start_level(same_level)


func _back_to_menu(node):
	#reset()
	combat.queue_free()
	get_tree().paused = false
	go_to_map()


func _on_Pause_back_to_menu(_combat):
	_combat.queue_free()
	get_tree().paused = false
	add_child(selection_screen)


func start_demo():
	var demo_players = []
	var player_rand = max(2, (randi() % len(all_species)) + 1)
	players = {}
	for i in range(player_rand):
		var other_species = all_species[i]
		var info_player = InfoPlayer.new()
		info_player.id = 'cpu'
		info_player.species = other_species
		info_player.cpu = true
		info_player.species_template = other_species
		players["cpu{id}".format({"id": i})] = info_player
	remove_child(selection_screen)
	next_level(true)


func add_cpu(how_many: int):
	"""
	Add cpu to the current pool of players
	"""
	var missing_species = TheUnlocker.get_ordered_species()
	for key in players:
		var player: InfoPlayer = players[key]
		var this_species_name = player.get_species_name()
		var i = 0
		for species in missing_species:
			if this_species_name == species.name:
				break
			i += 1
		missing_species.remove(i)

	var max_cpu = min(how_many, len(missing_species))
	max_cpu = min(max_cpu, global.MAX_PLAYERS)
	for i in range(max_cpu):
		var cpu_species = missing_species[i]
		var info_player = InfoPlayer.new()
		var id_player = 'cpu' + str(i)
		info_player.id = id_player
		info_player.cpu = true
		info_player.species = cpu_species
		players[id_player] = info_player
