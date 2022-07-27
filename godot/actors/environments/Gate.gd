extends Area2D

export var aperture := PI*0.9
signal goal_done

func _physics_process(delta):
	for body in get_overlapping_bodies():
		if body is Ship:
			var relative_position : Vector2 = body.global_position - global_position
			var relative_future_position : Vector2 = relative_position + body.velocity*delta
			var will_cross : bool = abs(relative_position.rotated(-global_rotation).angle()) <= PI/2 and abs(relative_future_position.rotated(-global_rotation).angle()) >= PI/2
			var relative_angle_of_incidence : float = body.velocity.rotated(-global_rotation).angle()
			
			if will_cross and abs(relative_angle_of_incidence) > PI/2 + (PI-aperture)/2:
				emit_signal("goal_done", body.get_player(), self, body.global_position)
				$AnimationPlayer.stop()
				$AnimationPlayer.play("Blink")
