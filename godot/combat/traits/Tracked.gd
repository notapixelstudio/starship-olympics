# USAGE
# hosts should call tick() inside their _integrate_forces()

extends Trait

var previous_global_positions : Array

func _enter_tree():
	if host == null:
		yield(self, 'ready')
		
	if not host.is_inside_tree():
		yield(host, 'ready')
		
	reset()
	
func reset():
	previous_global_positions = [get_host().global_position]
	
func tick():
	# remember our previous global positions
	previous_global_positions.push_back(get_host().global_position)
	if len(previous_global_positions) > 2:
		previous_global_positions.pop_front()
		
func get_previous_global_position(): # Vector2 or null
	if len(previous_global_positions) <= 1:
		return null
	return previous_global_positions[0]
	
