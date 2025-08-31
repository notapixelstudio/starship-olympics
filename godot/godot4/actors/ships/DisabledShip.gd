extends RigidBody2D
class_name DisabledShip

var _cloned_ship : Ship

func set_ship(ship: Ship) -> void:
	%Sprite2D.texture = ship.get_player().get_ship_image()
	%UnderSprite.texture = ship.get_player().get_ship_image()
	%UnderSprite.material.set_shader_parameter('color', ship.get_player().get_color())
	%MotionAutoTrail.gradient = ship.get_player().get_gradient()
	_cloned_ship = ship.clone()
	
func damage(hazard, damager) -> void:
	$HitAnimationPlayer.play("hit")
	
func beep():
	SoundEffects.play(%AudioStreamPlayer2D)
	
func _on_timer_timeout() -> void:
	_restore_ship()
	
func _restore_ship() -> void:
	_cloned_ship.global_position = global_position
	_cloned_ship.global_rotation = global_rotation
	_cloned_ship.linear_velocity = linear_velocity
	_cloned_ship.angular_velocity = angular_velocity
	Events.spawn_request.emit(_cloned_ship)
	queue_free()
	
