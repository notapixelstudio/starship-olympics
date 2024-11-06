# USAGE
# hosts should call tick() inside their _integrate_forces()

extends Trait

var _previous_global_positions : Array
var _previous_frame_ids : Array

func _enter_tree():
	if host == null:
		await self.ready
		
	if not host.is_inside_tree():
		await host.ready
		
	reset()
	
func reset():
	_previous_global_positions = [get_host().global_position]
	_previous_frame_ids = [0]
	
func tick():
	# remember the host's global position
	_previous_global_positions.push_back(get_host().global_position)
	_previous_frame_ids.push_back(Engine.get_physics_frames())
	if len(_previous_global_positions) > 3:
		_previous_global_positions.pop_front()
		_previous_frame_ids.pop_front()
		
func get_past_global_position(frames := 1): # Vector2 or null
	if frames > len(_previous_global_positions):
		return null
		
	if len(_previous_global_positions) <= 1:
		# just a single position or no positions at all
		return null
		
	for i in range(-frames-1, -len(_previous_global_positions)-1, -1):
		# avoid reading the current frame position
		if _previous_frame_ids[i] != Engine.get_physics_frames():
			return _previous_global_positions[i]
	return null
	
