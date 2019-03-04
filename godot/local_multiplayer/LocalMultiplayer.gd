extends Node

onready var selection_screen = $SelectionScreen
onready var gameover_screen = $GameOver/GameOverScreen
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

func setup_player(current_player : PlayerSpawner) -> InfoPlayer:
	var info_player = InfoPlayer.new()
	info_player.id = current_player.name
	info_player.controls = current_player.controls
	info_player.species = current_player.battler_template.species_name
	return info_player
	
func _ready():
	players = {}
	gameover_screen.hide()
	selection_screen.initialize(global.get_unlocked())
	selection_screen.connect("fight", self, "combat")

func combat(selected_players: Array):
	"""
	@param: selected_players : Array[Species] - Selected species from selection screen
	"""
	# TEST: analytics for selection
	var num_players : int = len(selected_players)
	GameAnalytics.add_to_event_queue(GameAnalytics.get_test_design_event("selection:num_players", num_players))

	gameover_screen.hide()
	var spawners = []
	var i = 1
	for player in selected_players:
		assert(player is Species)
		var player_info : InfoPlayer = from_species_to_info_player(player)
		spawners.append(from_info_to_spawner(player_info))
		players[player.id] = player_info
		GameAnalytics.add_to_event_queue(GameAnalytics.get_test_design_event("selection:species:"+player.species_template.species_name,i ))
		i +=1
	# LEVEL SELECTION
	var level_selection = level_selection_scene.instance()
	level_selection._initialize(str(num_players))
	add_child(level_selection)
	yield(level_selection, "arena_selected")
	print("back is ", level_selection.back)
	if level_selection.back:
		level_selection.queue_free()
		print("back is ", level_selection.back)
		return
	print("back is ", level_selection.back)
	var level_path = combat_scene + level_selection.current_level
	level_selection.queue_free()
	# END LEVEL SELECTION
	selected_level = load(level_path)
	combat = selected_level.instance()
	remove_child(selection_screen)
	combat.initialize(spawners)
	combat.connect("gameover", self, "gameover")
	connect("updated", combat, "hud_update")
	yield(get_tree().create_timer(0.5), "timeout")
	add_child(combat)
	# TEST: send the queue
	GameAnalytics.submit_events()

func from_info_to_spawner(player_info):
	var spawner = PlayerSpawner.new()
	spawner.controls = player_info.controls 
	spawner.species_template = player_info.species_template
	spawner.name = player_info.id
	spawner.info_player = player_info
	return spawner
	
func update_score(player_id:String, collectable_owner:String = ""):
	var score: int = 0
	if collectable_owner:
		score = players[player_id].update_collectables()
	else:
		score = players[player_id].update_death()
	emit_signal("updated", player_id, score, collectable_owner)

func gameover(winner:String, scores:Dictionary):
	get_tree().paused = true
	var players_scores = {}
	for player in players:
		var info_player = players[player]
		info_player.score = float(scores[player])
		players_scores[info_player.id] = info_player.to_dict()
	gameover_screen.initialize(winner, players_scores)
	gameover_screen.visible = true
	gameover_screen.raise()
	
	
func _on_GameOverScreen_rematch():
	gameover_screen.visible = false
	get_tree().paused = false
	combat.queue_free()
	var spawners = []
	for player in players:
		spawners.append(from_info_to_spawner(players[player]))
	combat = selected_level.instance()
	# remove_child(selection_screen)
	combat.initialize(spawners)
	combat.connect("gameover", self, "gameover")
	connect("updated", combat, "hud_update")
	yield(get_tree().create_timer(0.5), "timeout")
	add_child(combat)
