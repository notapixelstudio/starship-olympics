extends Node2D

@export var game_scene : PackedScene

var _current_game

func _ready():
	new_game()

func new_game():
	if _current_game:
		_current_game.queue_free()
	_current_game = game_scene.instantiate()
	add_child(_current_game)
	
	# hackish, I know
	#Engine.time_scale = 1 # doesn't work as expected
	get_tree().paused = false
	
func _input(event):
	# reset the game
	if event.is_action_pressed("force_reset"):
		new_game()
