enum MODES { IDLE, STEERING, ARRIVING, WANDER }
var max_vel = 0
var max_force = 0
var steering_force = Vector2()
var mode = 0

func _init():
	pass
#=============================================================
# Simple behaviors
#=============================================================
func steering( cur_pos, target_pos, cur_vel, delta ):
	var distance_to_target = target_pos - cur_pos
	var desired_vel = distance_to_target.normalized() * max_vel
	steering_force = ( desired_vel - cur_vel ) / delta
	steering_force = truncate( steering_force, max_force )
	return steering_force

func steering_and_arriving( cur_pos, target_pos, cur_vel, mindist, delta ):
	var distance_to_target = target_pos - cur_pos
	var desired_vel = distance_to_target.normalized() * max_vel
	if distance_to_target.length() < mindist:
		desired_vel *= distance_to_target.length() / mindist
		steering_force = ( desired_vel - cur_vel ) / delta
	else:
		steering_force = ( desired_vel - cur_vel ) / delta
		steering_force = truncate( steering_force, max_force )
	return steering_force

func fleeing( cur_pos, target_pos, cur_vel, mindist, delta ):
	var distance_to_target = target_pos - cur_pos
	if distance_to_target.length() > mindist:
		return Vector2()
	var desired_vel = -distance_to_target.normalized() * max_vel
	steering_force = ( desired_vel - cur_vel ) / delta
	steering_force = truncate( steering_force, max_force )
	return steering_force

func wander( cur_vel, cdist, cradius ):
	var circle_center = cur_vel.normalized() * cdist
	var wander_vector = Vector2( cradius, 0 ).rotated( randf() * 2 * PI )
	steering_force = circle_center + wander_vector
	steering_force = truncate( steering_force, max_force )
	return steering_force

func rect_bound( cur_pos, cur_vel, rect_bound, margin, offsetvel, delta ):
	steering_force = Vector2()
	if cur_pos.x > rect_bound.x - margin:
		steering_force.x = -offsetvel / delta
	elif cur_pos.x < margin:
		steering_force.x = offsetvel / delta
	if cur_pos.y > rect_bound.y - margin:
		steering_force.y = -offsetvel / delta
	elif cur_pos.y < margin:
		steering_force.y = offsetvel / delta
	return steering_force

func pursuit( cur_pos, target_pos, cur_vel, target_vel, delta ):
	return steering( cur_pos + target_vel * delta, target_pos, cur_vel, delta )


#=============================================================
# Sub-behaviors for flocking
#=============================================================
func separation( cur_pos, other_pos, scaling, mindist ):
	steering_force = Vector2( 0, 0 )
	var counter = 0
	for other in other_pos:
		var distance = other - cur_pos
		if distance.length() < mindist:
			counter += 1
			steering_force -= distance
	if counter > 0:
		steering_force /= counter
	#steering_force = _truncate( steering_force, max_force )
	steering_force *= scaling
	return steering_force

func alignment( cur_pos, other_pos, cur_vel, other_vel, mindist ):
	var desired_vel = Vector2()
	var counter = 0
	for idx in range( other_pos.size() ):
		if ( other_pos[idx] - cur_pos ).length() < mindist:
			desired_vel += other_vel[idx]
			counter += 1
	if counter > 0: desired_vel /= counter
	steering_force = ( desired_vel - cur_vel )
	#steering_force = _truncate( steering_force, max_force )
	return steering_force

func cohesion( cur_pos, other_pos, scaling, mindist ):
	var center = cur_pos
	var counter = 1
	for other in other_pos:
		if ( other - cur_pos ).length() < mindist:
			center += other
			counter += 1
	center /= counter
	steering_force = ( center - cur_pos ) * scaling
	#steering_force = _truncate( steering_force, max_force )
	return steering_force




func flocking( cur_pos, cur_vel, other_pos, other_vel, separation_dist, separation_scaling, alignment_dist, alignment_scaling, cohesion_dist, cohesion_scaling ):
	var separation_force = Vector2( 0, 0 )
	var separation_counter = 0
	
	var alignment_vel = Vector2( 0, 0 )
	var alignment_counter = 0
	
	var cohesion_center = cur_pos
	var cohesion_counter = 1
	
	for idx in range( other_pos.size() ):
		var distance_vec = other_pos[idx] - cur_pos
		var distance = distance_vec.length()
		
		if distance < separation_dist:
			separation_force -= distance_vec
			separation_counter += 1
		
		if distance < alignment_dist:
			alignment_vel += other_vel[idx]
			alignment_counter += 1
		
		if distance < cohesion_dist:
			cohesion_center += other_pos[idx]
			cohesion_counter += 1
		
	if separation_counter > 0: separation_force /= separation_counter
	separation_force *= separation_scaling
	
	if alignment_counter > 0: alignment_vel /= alignment_counter
	var alignment_force = ( alignment_vel - cur_vel ) * alignment_scaling
	
	cohesion_center /= cohesion_counter
	var cohesion_force = ( cohesion_center - cur_pos ) * cohesion_scaling
	
	steering_force = separation_force + alignment_force + cohesion_force
	return steering_force



#=============================================================
# support functions
#=============================================================
func truncate( vec, val ):
	if vec.length() > val:
		vec = vec.normalized() * val
	return vec
