extends Node2D

export (float, 0, 1, 0.01) var match_progress_trigger = 2/3.0
export (float, 0, 10, 0.01) var jitter = 0.5

var total_time : float
var content = []

func _ready():
	store()
	global.the_match.connect('setup', self, '_on_match_setup')
	global.the_match.connect('tick', self, '_on_match_tick')
	
func _on_match_setup():
	total_time = global.the_match.time_left
	
func _on_match_tick(time_left):
	if is_active() and time_left < (1-match_progress_trigger)*total_time:
		yield(get_tree().create_timer(jitter*randf()), "timeout")
		unstore()
	
func store():
	# store children outside the tree
	for child in get_children():
		content.append(child)
		remove_child(child)
		
func unstore():
	# put children back into the tree
	for child in content:
		add_child(child)
	content = []
	
func is_active():
	return len(content) > 0
	
