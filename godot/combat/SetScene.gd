extends Node

export var set1 : Resource # Planet
export var set2 : Resource # Planet
export var set3 : Resource # Planet
export var set4 : Resource # Planet
export var set5 : Resource # Planet

export var num_players = 2

onready var all_sets = [set1, set2, set3, set4, set5]
var played_levels = []
var levels = []
func _ready():
	for s in all_sets:
		if s:
			assert(s is Planet)
			var set: Planet = s
			levels += set.get_levels(num_players)
	
	# FIXME shuffling logic should be here
	
	next_level()
	
func next_level():
	if len(levels) <= 0:
		levels = played_levels.duplicate()
	var last_played = levels.pop_back()
	played_levels.append(last_played)
	var combat = last_played.instance()
	combat.connect("continue_session", self, "_on_continue_session", [combat])
	combat.connect("skip", self, "_on_continue_session", [combat])
	combat.connect("restart", self, "_on_restart", [combat])
	add_child(combat)
	yield(combat, "battle_start")
	combat.standalone = false

func _on_restart(combat):
	var same_level = played_levels.back()
	combat.queue_free()
	get_tree().paused = false
	yield(combat, 'tree_exited')
	levels.append(same_level)
	next_level()
	
	
func _on_continue_session(combat, session_over = false):
	"""
	This callback will be called after the gameover.
	Will handle if there is something to unlock
	"""
	combat.queue_free()
	get_tree().paused = false
	yield(combat, 'tree_exited')
	if session_over:
		print("OVER and BOOM")
	else:
		next_level()
	
