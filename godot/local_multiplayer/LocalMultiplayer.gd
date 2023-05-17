extends Node

onready var selection_screen = $SelectionScreen

const menu_scene = "res://ui/menu_scenes/title_screen/MainScreen.tscn"
const combat_scene = "res://combat/levels/"
export var map_scene: PackedScene
export var celebration_scene: PackedScene
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
	Events.connect('continue_after_session_ended', self, '_on_continue_after_session_ended')
	
	Events.connect('nav_to_menu', self, '_on_nav_to_menu')
	Events.connect('nav_to_map', self, '_on_nav_to_map')
	Events.connect('nav_to_character_selection', self, '_on_nav_to_character_selection')
	
	var p = parse_json(global.read_file("user://games/latest.json"))
	if typeof(p) == TYPE_ARRAY or typeof(p):
		print("Correctly loaded session to continue") # Prints "hello"
	else:
		push_error("Unexpected results.")
	var unfinished_game = {}
	if not unfinished_game.empty():
		setup_continue_game(unfinished_game)
#		var confirm = load("res://special_scenes/combat_UI/gameover/AreYouSure.tscn").instance()
#		get_tree().paused = true
#		$"%AddOnScreen".visible = true
#		$"%AddOnScreen".add_child(confirm)
#		confirm.setup("continue")
#		yield(confirm, "choice_selected")
#		if confirm.choice:
#			print("setup with new data {data}".format({"data": unfinished_game}))
#			self.setup_continue_game(unfinished_game)
#		confirm.queue_free()
#		get_tree().paused = false
#		$"%AddOnScreen".visible = false
		
	# will save the game before starting a new game 
	# So all the options will be saved
	persistance.save_game()
	
func setup_continue_game(game_data: Dictionary):
	# setup players
	players = {}
	for player_data in game_data.get("players", []):
		var infoplayer := InfoPlayer.new()
		infoplayer.set_from_dictionary(player_data)
		players[infoplayer.get_id()] = infoplayer
	yield(get_tree(), "idle_frame")
	# setup deck
	global.new_game(players.values(), game_data)
	yield(get_tree(), "idle_frame")	
	
	create_map(game_data.get("session", {}))
	print("Last game played was {game}. Will be removed from last_played".format({"game":global.the_game.deck.played_pile.back()}))
	navigate_to_map()
	

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
		
	if global.demo:
		add_cpu([2, 3, 4][randi()%3])
		
	# if single player, add a CPU
	var num_CPUs = 0 if len(players) > 1 else 1
	if len(players) == 0:
		num_CPUs = 2
	add_cpu(num_CPUs)
	
	# map initialization
	remove_child(selection_screen)
	remove_child(parallax)
	
	# add startdeck choosing
	var playlists = global.get_playlist_starting_deck([ TheUnlocker.NEW, TheUnlocker.UNLOCKED])
	if len(playlists) > 1:
		var choose_deck_scene = load("res://ui/minigame_list/DeckListScreen.tscn").instance()
		add_child(choose_deck_scene)
		yield(Events, "selection_starting_deck_over")
		if is_instance_valid(choose_deck_scene):
			choose_deck_scene.queue_free()
		#TheUnlocker.unlock_element("starting_decks", global.starting_deck_id)
	
	global.new_game(players.values())
	safe_destroy_combat()
	
	create_map()
	navigate_to_map()
	
var players_sequence : Array = []
var selected_sets_by_player : Dictionary = {}
var minigame_pools : Dictionary = {}
var last_card: DraftCard
var last_minigame: Minigame

func _on_minigame_selected(picked_card:DraftCard):
	# start match
	print(picked_card is MysteryCard)
	var minigame = picked_card.get_minigame()
	minigame.increase_times_started()
	start_new_match(picked_card, minigame)
	
func continue_after_session_over() -> void:
	"""
	After a session has ended, Celebrate winner.
	"""
	global.sessions_played +=1 # WE are sure that sessions is over
	var deck: Deck = global.the_game.get_deck()
	
	"""
	if deck.is_playlist():
		var playlists = global.get_playlist_starting_deck(TheUnlocker.HIDDEN)
		playlists.shuffle()
		if len(playlists) > 0:
			var to_be_unlocked_deck = playlists.back()
			print("Unlocking a new playlist" + to_be_unlocked_deck.get_id())
			TheUnlocker.unlock_element("starting_decks",to_be_unlocked_deck.get_id())
			
	Unlocking disabled Issue #1022
	
	if global.sessions_played == 1:
		var unlock: PackedScene = load("res://special_scenes/unlock_screen/NewDraft.tscn")
		$"%UnlockSceneClassic".unlock(unlock, true, "first_unlock")
		yield($"%UnlockSceneClassic", "unlocking_animation_over")
	elif global.sessions_played == 2:
		var to_be_unlocked_deck := "winter"
		var this_deck_name: String = global.starting_deck
		var unlock: PackedScene = load("res://special_scenes/unlock_screen/NewDraft.tscn")
		$"%UnlockSceneClassic".unlock(unlock, false, "second_unlock")
		yield($"%UnlockSceneClassic", "unlocking_animation_over")
		TheUnlocker.unlock_element("starting_decks",to_be_unlocked_deck)
		# add startdeck choosing
		var confirm = load("res://special_scenes/combat_UI/gameover/AreYouSure.tscn").instance()
		$"%UnlockSceneClassic".add_child(confirm)
		confirm.setup("deck")
		yield(confirm, "choice_selected")
		if confirm.choice:
			global.starting_deck = to_be_unlocked_deck
			global.new_game(players.values())
		confirm.queue_free()
	"""
	# a session has been completed with this deck, so mark it as not new anymore and unlock new ones from it
	if not global.demo: # do not unlock new content if we are in demo mode
		TheUnlocker.unlock_element("starting_decks", global.starting_deck_id)
		var decks = global.get_resources(Deck.DECK_PATH)
		var starting_deck: StartingDeck = global.get_actual_resource(decks, global.starting_deck_id)
		for unlock in starting_deck.get_unlocks():
			TheUnlocker.unlock_element("starting_decks", unlock, TheUnlocker.NEW)

	navigate_to_celebration()
	# navigate_to_map()
	
func start_new_match(picked_card: DraftCard, minigame: Minigame):
	"""
	This function given a card and its minigame, will start a match
	"""

	$TransitionScreen.transition()
	yield($TransitionScreen, "transitioned")
	remove_child(map)
	$"%UnlockSceneClassic".reset()
	# show tutorial if this minigame has one, and the minigame has not been already played
	if minigame.has_tutorial() and not global.demo:
		var tutorial = minigame.get_tutorial_scene().instance()
		# check if we are playing the introductory playlist
		if global.starting_deck_id == 'first' and minigame.is_first_time_started():
			add_child(tutorial)
			yield(tutorial, 'over')
			
			$TransitionScreen.transition()
			yield($TransitionScreen, "transitioned")
			tutorial.queue_free()
	
	start_match(picked_card, minigame)
	


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
	add_child(combat)
	Events.emit_signal("match_started")
	
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
		continue_after_session_over()
	else:
		if not map.is_inside_tree():
			add_child(map)
			
func _on_continue_after_session_ended():
	persistance.delete_latest_game()
	start_fight(players.values(), "session_ended")
	
func _on_Pause_restart():
	safe_destroy_combat()
	start_match(last_card, last_minigame)
	
func _on_nav_to_menu():
	persistance.save_game_as_latest()
	global.safe_destroy_game()
	get_tree().change_scene(menu_scene)
	
func _on_nav_to_character_selection():
	global.safe_destroy_game()
	safe_destroy_combat()
	if map and is_instance_valid(map):
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
	
func create_map(data:= {}):
	global.new_session(data)
	map = map_scene.instance()

var celebration: HallOfFame

func navigate_to_celebration():
	safe_destroy_combat()
	var champion: InfoChampion = InfoChampion.new()
	var this_session: TheSession = global.get("session")
	this_session.get_last_winners()[0].to_dict()
	champion.player = this_session.get_last_winners()[0].to_dict()
	champion.session_info = this_session.to_dict()
	if champion.is_cpu():
		Events.emit_signal("continue_after_session_ended")
	else:
		celebration = celebration_scene.instance()
		celebration.add_champion = true
		add_child(celebration)
		
		celebration.set_champion(champion)

func navigate_to_map(session_over := false):
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


func _exit_tree():
	global.local_multiplayer = null
	
