extends RigidBody2D
class_name Cargo

@export var drop_distance := 0.0

func place_and_push(dropper, velocity, direction:='forward') -> void:
	var dir = 1.0 if direction == 'forward' else -1.0
	global_position = dropper.global_position + dir*Vector2(drop_distance,0).rotated(dropper.global_rotation)
	linear_velocity = velocity if direction == 'forward' else -velocity

func touched_by(toucher : Ship):
	Events.sth_loaded.emit(toucher, self)
	queue_free()

func get_texture() -> Texture:
	return %Sprite2D.texture

func hit():
	%SpriteAnimation.stop()
	%SpriteAnimation.play('Hit')
