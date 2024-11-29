extends RigidBody2D

## constants for basic movement
const THRUST := 400
## 9 because we enlarged the radius of the ship's collision shape by 3
var rotation_torque := 380000 # 130000 # 49000*9 

var target_velocity := Vector2(0, 0)
var rotation_request := 0.0

func get_target_velocity() -> Vector2:
	return target_velocity
	
func set_target_velocity(v: Vector2) -> void:
	target_velocity = v
	set_constant_force(target_velocity * THRUST)
	
func set_rotation_request(v: float) -> void:
	rotation_request = v
	set_constant_torque(min(PI/2, rotation_request) * rotation_torque)
	

func _on_touch_area_2d_body_entered(body: Node2D) -> void:
	if body is Treasure:
		body.touched_by(self)

func touched_by(sth) -> void:
	if sth.has_method('is_dashing') and sth.is_dashing():
		queue_free()
	elif sth is Ship:
		sth.die()
		queue_free()
