extends Node2D

@export var game_scene_2p : PackedScene
@export var game_scene_3p: PackedScene
@export var game_scene_4p: PackedScene

var _current_game

func _ready():
	new_game(game_scene_2p)

func new_game(game_scene: PackedScene):
	if _current_game:
		remove_child(_current_game)
		_current_game.queue_free()
		
	_current_game = game_scene.instantiate()
	_current_game.session = SingleMatchSession.new()
	add_child(_current_game)
	
	# hackish, I know
	#Engine.time_scale = 1 # doesn't work as expected
	get_tree().paused = false
	
func _input(event):
	# reset the game2
	if event.is_action_pressed("force_reset_2p"):
		new_game(game_scene_2p)
	elif event.is_action_pressed("force_reset_3p"):
		new_game(game_scene_3p)
	elif event.is_action_pressed("force_reset_4p"):
		new_game(game_scene_4p)
