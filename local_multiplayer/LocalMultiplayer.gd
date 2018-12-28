extends Node

onready var selection_screen = $SelectionScreen
const combat_scene = "res://combat/levels/"

var players : Dictionary

func setup_player(current_player : PlayerSpawner) -> InfoPlayer:
	var info_player = InfoPlayer.new()
	info_player.controls = current_player.controls
	info_player.cpu = false
	info_player.playable = true
	info_player.species = current_player.battler_template.species_name
	return info_player
	
func _ready():
	selection_screen.initialize(global.get_unlocked())
	selection_screen.connect("fight", self, "combat")

func combat(selected_players: Array):
	"""
	
	"""
	var spawners = []
	for player in selected_players:
		assert(player is Species)
		var spawner = PlayerSpawner.new()
		spawner.controls = player.controls 
		spawner.battler_template = player.battler_template
		spawner.name = player.name
		spawners.append(spawner)
		players[player.name] = setup_player(spawner)
	var num_players : int = len(selected_players)
	var level = load(combat_scene + str(num_players) + "players.tscn")
	var combat = level.instance()
	remove_child(selection_screen)
	combat.initialize(spawners)
	yield(get_tree().create_timer(0.5), "timeout")
	add_child(combat)