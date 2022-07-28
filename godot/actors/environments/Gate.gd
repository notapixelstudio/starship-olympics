extends Area2D

export var width := 550.0
export var aperture := PI*0.99
#export var crossing_while_still_tolerance := 0.3

signal goal_done


func _physics_process(delta):
	for body in get_overlapping_bodies():
		if body is Ship:
			var relative_position : Vector2 = body.global_position - global_position
			var relative_future_position : Vector2 = relative_position + body.linear_velocity*delta
			var top_end := Vector2(0, -width/2).rotated(global_rotation)
			var bottom_end := Vector2(0, width/2).rotated(global_rotation)
			var crossing_point = Geometry.segment_intersects_segment_2d(relative_position, relative_future_position, top_end, bottom_end)
			#var is_crossing_while_still : bool = relative_position.distance_to(relative_future_position) < crossing_while_still_tolerance and Geometry.get_closest_point_to_segment_2d(relative_position, top_end, bottom_end).distance_to(relative_position) < crossing_while_still_tolerance
			var will_cross : bool = crossing_point is Vector2# or is_crossing_while_still
			var relative_angle_of_incidence : float = body.linear_velocity.rotated(-global_rotation).angle()
			
			if will_cross and abs(relative_angle_of_incidence) > PI/2 + (PI-aperture)/2:
				emit_signal("goal_done", body.get_player(), self, body.global_position)
				$AnimationPlayer.stop()
				$AnimationPlayer.play("Blink")
				
