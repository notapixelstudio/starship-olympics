extends Node

onready var selection_screen = $SelectionScreen

const menu_scene = "res://ui/menu_scenes/title_screen/MainScreen.tscn"
const combat_scene = "res://combat/levels/"
export var map_scene: PackedScene
export var tutorial_scene: PackedScene

var games = {}  # {sport.name : Resource}

var all_species = []
onready var parallax = $ParallaxBackground
var map # MapArena
var combat = null

# dictionary of InfoPlayer of players that will actually play
var players: Dictionary  # of InfoPlayer

signal updated


func _ready():
	var unlocked_species = TheUnlocker.get_unlocked_list("species")
	for species_id in unlocked_species:
		all_species.append(global.get_species(species_id))
		
	players = {}
	selection_screen.connect("fight", self, "start_fight")
	selection_screen.connect("back", self, "back")
	global.local_multiplayer = self
	
	Events.connect("minigame_selected", self, "_on_minigame_selected")
	Events.connect('continue_after_game_over', self, '_on_continue_after_game_over')
	
	Events.connect('nav_to_menu', self, '_on_nav_to_menu')
	Events.connect('nav_to_map', self, '_on_nav_to_map')
	Events.connect('nav_to_character_selection', self, '_on_nav_to_character_selection')
	
	# will save the game before starting a new game 
	# So all the options will be saved
	persistance.save_game()
	
func _exit_tree():
	global.local_multiplayer = null

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
	
	# if single player, add a CPU
	var num_CPUs = 0 if len(players) > 1 else 1
	add_cpu(num_CPUs)
	
	global.new_game(players.values())
	
	safe_destroy_combat()
	# map initialization
	remove_child(selection_screen)
	remove_child(parallax)
	
	create_map()
	navigate_to_map()
	
var players_sequence : Array = []
var selected_sets_by_player : Dictionary = {}
var minigame_pools : Dictionary = {}
var last_card: DraftCard
var last_minigame: Minigame

func _on_minigame_selected(picked_card:DraftCard, minigame: Minigame):
	# start match
	minigame.increase_times_started()
	start_new_match(picked_card, minigame)
	
	
func continue_fight() -> void:
	"""
	After a session has ended, return to the map.
	"""
	navigate_to_map()
	
func start_new_match(picked_card: DraftCard, minigame: Minigame):
	"""
	This function given a card and its minigame, will start a match
	"""

	$TransitionScreen.transition()
	yield($TransitionScreen, "transitioned")
	remove_child(map)
	
	# show tutorial if this is the first match of the game
	if global.is_before_first_match_of_the_game():
		var tutorial = tutorial_scene.instance()
		add_child(tutorial)
		yield(tutorial, 'over')
		
		$TransitionScreen.transition()
		yield($TransitionScreen, "transitioned")
		tutorial.queue_free()
	
	start_match(picked_card, minigame)

func get_next_minigame(set):
	# replenish pool if empty
	if len(minigame_pools[set.name]) == 0:
		minigame_pools[set.name] = set.get_minigames()
		minigame_pools[set.name].shuffle()
		
	return minigame_pools[set.name].pop_back()

func start_match(picked_card: DraftCard, minigame: Minigame, demo = false):
	global.new_match()
	global.the_match.set_minigame(minigame)
	global.the_match.set_draft_card(picked_card)
	combat = minigame.get_level(global.the_game.get_number_of_players()).instance()
	last_card = picked_card
	last_minigame = minigame
	
	combat.connect("restart", self, "_on_Pause_restart")
	#combat.connect("continue_session", self, "_on_continue_session", [combat])
	connect("updated", combat, "hud_update")

	for child in get_children():
		if child is Arena:
			child.queue_free()
			yield(child, 'tree_exited')
	combat.demo = demo
	add_child(combat)
	
func safe_destroy_combat():
	if combat:
		remove_child(combat)
		combat.queue_free()
		combat = null

func _on_continue_after_game_over(session_over = false):
	"""
	This callback will be called after the gameover.
	"""
	safe_destroy_combat()
	# FIXME: WHatever happens here is not really deterministic
	# maybe becaaauuse the combat isn't freeed when maaap is added
	# maybe there is more than one maaaaap at the same tiiiiime
	if session_over:
		continue_fight()
	else:
		if not map.is_inside_tree():
			add_child(map)
	
func _on_Pause_restart():
	safe_destroy_combat()
	start_match(last_card, last_minigame)


func _on_nav_to_menu():
	global.safe_destroy_game()
	get_tree().change_scene(menu_scene)
	
func _on_nav_to_character_selection():
	global.safe_destroy_game()
	safe_destroy_combat()
	map.queue_free()
	if not parallax.is_inside_tree():
		add_child(parallax)
		add_child(selection_screen)
	selection_screen.reset()
	if global.demo:
		selection_screen.deselect()

func _on_nav_to_map():
	global.safe_destroy_session()
	map.queue_free()
	create_map()
	navigate_to_map()
	
func create_map():
	map = map_scene.instance()
	
func navigate_to_map():
	safe_destroy_combat()
	# map initialization
	remove_child(selection_screen)
	remove_child(parallax)
	add_child(map)


func add_cpu(how_many: int):
	"""
	Add cpu to the current pool of players
	"""
	var missing_species = global.get_ordered_species()
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
		
		var id_player = null
		for x in range(global.MAX_PLAYERS):
			var maybe_id = 'p'+str(x+1)
			if not(maybe_id in players):
				id_player = maybe_id
				break
		assert(id_player != null)
		
		info_player.id = id_player
		info_player.cpu = true
		info_player.species = cpu_species
		players[id_player] = info_player

