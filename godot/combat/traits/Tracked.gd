extends Trait

var previous_global_positions : Array

func _ready():
	previous_global_positions = [get_host().global_position]
	
func _physics_process(delta):
	# remember our previous global positions
	previous_global_positions.push_back(get_host().global_position)
	if len(previous_global_positions) > 2:
		previous_global_positions.pop_front()

func get_previous_global_position(): # Vector2 or null
	if len(previous_global_positions) <= 1:
		return null
	return previous_global_positions[0]
	
