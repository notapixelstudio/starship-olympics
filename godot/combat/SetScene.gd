extends Node

export var set1 : Resource # Planet
export var set2 : Resource # Planet
export var set3 : Resource # Planet
export var set4 : Resource # Planet
export var set5 : Resource # Planet

export var num_players = 2

onready var all_sets = [set1, set2, set3, set4, set5]
var combat 
var levels = []
func _ready():
	for s in all_sets:
		if s:
			assert(s is Planet)
			var set: Planet = s
			levels += set.get_levels(num_players)
	next_level()
	
func next_level():
	combat = levels.pop_back().instance()
	combat.connect("continue_session", self, "_on_continue_session")
	combat.connect("skip", self, "_on_continue_session")
	add_child(combat)
	yield(combat, "battle_start")
	combat.standalone = false

func _on_continue_session(session_over = false):
	"""
	This callback will be called after the gameover.
	Will handle if there is something to unlock
	"""
	combat.queue_free()
	get_tree().paused = false
	if session_over:
		print("OVER and BOOM")
	else:
		next_level()
	
