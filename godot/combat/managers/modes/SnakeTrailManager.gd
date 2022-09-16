extends Manager

@export var max_trail_length: int = 300
@export var growth: int = 2


func _process(delta):
	for trail in get_tree().get_nodes_in_group("Trails"):
		trail.trail_f += growth * delta
		#trail.trail_length = min(trail.trail_f, max_trail_length)
