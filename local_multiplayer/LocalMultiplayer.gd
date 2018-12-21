extends Node

onready var selection_screen = $SelectionScreen
const combat_scene = "res://combat/levels/"

	
var current_players : Dictionary

func setup_player(current_player):
	var info_player = InfoPlayer.new()
	info_player.controls = current_player.controls
	info_player.cpu = false
	info_player.playable = true
	info_player.species = current_player.species
	current_players[current_player.name] = info_player
	
func _ready():
	selection_screen.initialize(global.get_unlocked())
	selection_screen.connect("fight", self, "combat")

func combat(players: Array):
	"""
	each element of players needs a controls and battler_template members
	"""
	for player in players:
		setup_player(player)
	var num_players : int = len(players)
	var level = load(combat_scene + str(num_players) + "players.tscn")
	var combat = level.instance()
	remove_child(selection_screen)
	yield(get_tree().create_timer(1), "timeout")
	combat.initialize(players)
	add_child(combat)
	print(current_players)