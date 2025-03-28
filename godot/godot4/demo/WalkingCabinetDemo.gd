extends Node2D

@export var game_scene_2p : PackedScene
@export var game_scene_3p: PackedScene
@export var game_scene_4p: PackedScene
@export var game_scene_1pve: PackedScene
@export var game_scene_2pve: PackedScene
@export var game_scene_3pve: PackedScene
@export var game_scene_4pve: PackedScene

var mode = 'vs'
var player_count = 2

var _current_game

func _ready():
	new_game(game_scene_2p)

func new_game(game_scene: PackedScene):
	if _current_game:
		remove_child(_current_game)
		_current_game.queue_free()
		
	_current_game = game_scene.instantiate()
	var sesh 
	if mode == 'vs':
		sesh = SingleMatchSession.new()
	else:
		sesh = SinglePveMatchSession.new()
	_current_game.session = sesh
	add_child(_current_game)
	
	# hackish, I know
	Engine.time_scale = 1 # doesn't work as expected
	get_tree().paused = false
	
func _input(event):
	# reset the game2
	if event.is_action_pressed("change_mode_vs"):
		mode = 'vs'
	elif event.is_action_pressed("change_mode_coop"):
		mode = 'coop'
	elif event.is_action_pressed("force_reset_1p"):
		player_count = 1
	elif event.is_action_pressed("force_reset_2p"):
		player_count = 2
	elif event.is_action_pressed("force_reset_3p"):
		player_count = 3
	elif event.is_action_pressed("force_reset_4p"):
		player_count = 4
	
	if mode == 'vs':
		if player_count == 2:
			new_game(game_scene_2p)
		elif player_count == 3:
			new_game(game_scene_3p)
		elif player_count == 4:
			new_game(game_scene_4p)
	else:
		if player_count == 1:
			new_game(game_scene_1pve)
		elif player_count == 2:
			new_game(game_scene_2pve)
		elif player_count == 3:
			new_game(game_scene_3pve)
		elif player_count == 4:
			new_game(game_scene_4pve)
