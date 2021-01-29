extends Node

var hills

func get_all_hills():
	return get_tree().get_nodes_in_group('hill')

func _ready():
	hills = get_all_hills()
	for hill in hills:
		hill.connect('lost', self, '_on_hill_lost')
	
func next_hill(previous_hill):
	# only one hill is active at a given time
	for hill in hills:
		hill.set_active(false)
		
	# skip the previous hill
	# FIXME should also avoid zones with ships inside them
	var next_hill = previous_hill
	while next_hill == previous_hill:
		next_hill = hills[randi() % len(hills)]
	
	next_hill.set_active(true)
	
func _on_hill_lost(lost_hill):
	yield(get_tree().create_timer(1), "timeout")
	next_hill(lost_hill)
	
func _process(delta):
	for hill in hills:
		if hill.get_active() and hill.get_player() != null:
			global.the_match.add_score(hill.get_player().id, delta)
		
