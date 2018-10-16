# script arena
extends Node

var Ship
var player2
var width
var height
var someone_died = 0

var n_players = 2
export (float) var size_multiplier = 1.0

var debug = false
onready var DebugNode = get_node("Debug/DebugNode")
onready var Battlefield = get_node("Battlefield")
onready var Pause = get_node("Pause/end_battle")


func _ready():
	global.this_run_time = OS.get_ticks_msec()
	n_players = global.num_players
	
		
	debug = global.debug
	DebugNode.visible = debug
	
	someone_died = 0
	# compute the battlefield size
	width = OS.window_size.x * size_multiplier
	height = OS.window_size.y * size_multiplier
	
	#Analytics
	analytics.start_elapsed_time()
	
	# setup spawner
	for spawner in Battlefield.get_children():
		if spawner.is_in_group("spawner"):
			spawner.spawn()

func update_score(dead_player):
	# TODO: what if both of them died
	var updated_label
	someone_died +=1
	global.scores[dead_player] -= 1
	print(dead_player + str(global.scores))
	
	# after X seconds let's stop all, this is done due to avoid double popup
	# and here it can happen double KO. Needs standoff
	if global.gameover:
		if global.scores[dead_player] <= 0:
			global.standoff = true
		
	# TODO: gameover condition doesn't need to be here
	if global.scores[dead_player] <= 0:
		global.gameover = true
	
	if someone_died >= global.num_players-1:
		yield(get_tree().create_timer(2.0), "timeout")
		Pause.update_score()

func _input(event):
	var debug_pressed = event.is_action_pressed("debug")
	if debug_pressed:
		debug = not debug
		DebugNode.visible = debug
		
	# reset by command only through debug
	if event.is_action_pressed('continue') and debug:
		reset()
	
func _process(delta):
	for node in Battlefield.get_children():
		if node.is_in_group("AI"):
			DebugNode.get_node("VBoxContainer/AI").text = "AI dist: "+ str(node.dist)
			DebugNode.get_node("VBoxContainer/pos_dist").text = "AI direction: "+ str(node.pos_dist)
			var danger = false
			if node.steer_away:
				danger= true
			DebugNode.get_node("VBoxContainer/danger").text = str(danger)
			
			
func reset():
	someone_died = false
	get_tree().reload_current_scene()
	