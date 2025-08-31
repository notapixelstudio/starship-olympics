extends RigidBody2D
class_name DisabledShip

var player : Player

func get_player() -> Player:
	return player
	
func set_player(v: Player) -> void:
	player = v
	%Sprite2D.texture = player.get_ship_image()
	%UnderSprite.texture = player.get_ship_image()
	%UnderSprite.material.set_shader_parameter('color', player.get_color())
	
func damage(hazard, damager) -> void:
	$HitAnimationPlayer.play("hit")
	
func beep():
	SoundEffects.play(%AudioStreamPlayer2D)
	
func _on_timer_timeout() -> void:
	_restore_ship()
	
func _restore_ship() -> void:
	var ship = Ship.create(get_player())
	ship.global_position = global_position
	ship.global_rotation = global_rotation
	ship.linear_velocity = linear_velocity
	ship.angular_velocity = angular_velocity
	get_parent().add_child.call_deferred(ship)
	queue_free()
	
