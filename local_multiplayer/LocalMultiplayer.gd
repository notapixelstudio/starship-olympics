extends Node

onready var selection_screen = $SelectionScreen
onready var gameover_screen = $GameOver/GameOverScreen
const combat_scene = "res://combat/levels/"
var combat = null

# dictionary of InfoPlayer of players that will actually play
var players : Dictionary

signal updated

func from_species_to_info_player(selection_species: Species) -> InfoPlayer:
	var info_player = InfoPlayer.new()
	info_player.id = selection_species.name
	info_player.controls = selection_species.controls
	info_player.species_template = selection_species.battler_template
	return info_player

func setup_player(current_player : PlayerSpawner) -> InfoPlayer:
	var info_player = InfoPlayer.new()
	info_player.id = current_player.name
	info_player.controls = current_player.controls
	info_player.species = current_player.battler_template.species_name
	return info_player
	
func _ready():
	gameover_screen.hide()
	selection_screen.initialize(global.get_unlocked())
	selection_screen.connect("fight", self, "combat")

func combat(selected_players: Array):
	"""
	@param: selected_players : Array[Species] - Selected species from selection screen
	"""
	gameover_screen.hide()
	var spawners = []
	for player in selected_players:
		assert(player is Species)
		var player_info = from_species_to_info_player(player)
		var spawner = PlayerSpawner.new()
		spawner.controls = player.controls 
		spawner.battler_template = player.battler_template
		spawner.name = player.name
		print(spawner.name , " vs ", player.name, " in combat")
		spawners.append(spawner)
		players[player.id] = setup_player(spawner)
	var num_players : int = len(selected_players)
	print(players)
	var level_path = combat_scene + str(num_players) + "players.tscn"
	var level = load(level_path)
	combat = level.instance()
	remove_child(selection_screen)
	combat.initialize(spawners)
	#combat.connect("score_updated", self, "update_score")
	combat.connect("gameover", self, "gameover")
	connect("updated", combat, "hud_update")
	yield(get_tree().create_timer(0.5), "timeout")
	add_child(combat)

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
	yield(get_tree().create_timer(10), "timeout")
	

func _on_GameOverScreen_rematch():
	get_tree().paused = false
	combat.queue_free()
	get_tree().reload_current_scene()
