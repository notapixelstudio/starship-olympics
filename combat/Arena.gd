# script arena
extends Node

var width
var height
var someone_died = 0

var n_players = 2
export (float) var size_multiplier = 1.0

var debug = false
onready var DebugNode = get_node("Debug/DebugNode")
onready var Battlefield = get_node("Battlefield")
onready var Pause = get_node("Pause/end_battle")

var run_time = 0
func compute_arena_size():
	"""
	compute the battlefield size
	"""
	width = OS.window_size.x * size_multiplier
	height = OS.window_size.y * size_multiplier
	return true
	
func _ready():
	# in order to get the size
	get_tree().get_root().connect("size_changed", self, "compute_arena_size")
	run_time = OS.get_ticks_msec()
	
	# get number of players
	n_players = get_num_players()
	
	# Analytics
	analytics.start_elapsed_time()
	
	# setup spawners
	for spawner in Battlefield.get_children():
		if spawner.is_in_group("spawner"):
			spawner.spawn()

func _unhandled_input(event):
	var debug_pressed = event.is_action_pressed("debug")
	if debug_pressed:
		debug = not debug
		DebugNode.visible = debug
		
	# reset by command only through debug
	if event.is_action_pressed('continue') and debug:
		reset()
	
func reset(level):
	someone_died = false
	get_tree().change_scene_to(load("res://screens/game_screen/levels/"+level))
	#get_tree().reload_current_scene()

func get_num_players():
	return 4
