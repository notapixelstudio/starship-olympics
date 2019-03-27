extends Node

onready var selection_screen = $SelectionScreen

const combat_scene = "res://combat/levels/"
const level_selection_scene = preload("res://local_multiplayer/LevelSelection.tscn")
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
	var level_selection = level_selection_scene.instance()
	level_selection.initialize(str(num_players), players)
	add_child(level_selection)
	yield(level_selection, "arena_selected")
	if level_selection.back:
		level_selection.queue_free()
		return
	current_level = level_selection.current_level
	start_level(current_level)

	level_selection.queue_free()
	
	# TEST: send the queue
	GameAnalytics.submit_events()

var current_level : String # we will save here which level we are playing

func start_level(_level):
	var level_path = combat_scene + _level
	# END LEVEL SELECTION

	selected_level = load(level_path)
	combat = selected_level.instance()
	remove_child(selection_screen)
	combat.initialize(players)
	combat.connect("restart", self, "_on_Pause_restart", [combat])
	combat.connect("back_to_menu", self, "_on_Pause_back_to_menu", [combat])
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
	

func _on_GameOverScreen_rematch(node):
	node.queue_free()
	get_tree().paused = false
	combat.queue_free()
	start_level(current_level)
func _on_Pause_restart(_combat):
	_combat.queue_free()
	print("restart multiplayer")
	get_tree().paused = false
	start_level(current_level)


func _on_GameOverScreen_back_to_menu(node):
	print("RESTARTO")
	node.queue_free()
	combat.queue_free()
	get_tree().paused = false
	add_child(selection_screen)
	
func _on_Pause_back_to_menu(_combat):
	_combat.queue_free()
	get_tree().paused = false
	add_child(selection_screen)