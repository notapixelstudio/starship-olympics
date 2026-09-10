extends RigidBody2D
class_name Shapeoid


@export var speed := 500.0
@export var appear_scene : PackedScene

var _direction := 0.0

func _move() -> void:
	set_constant_force(speed*Vector2.RIGHT.rotated(_direction))

# appear effect "interface", like treasures
func create_appear_effect() -> Node2D:
	var appear = appear_scene.instantiate()
	appear.set_texture(get_appear_texture())
	return appear
	
func get_texture() -> Texture:
	return %Sprite2D.texture
	
func get_appear_texture() -> Texture:
	return get_texture()

func _on_touch_area_2d_body_entered(sth: Node2D) -> void:
	if sth is BubbleBullet: # FIXME Bullet abstract superclass?
		Events.collision.emit(sth, self)
	# what about treasures?
	# ...

func die(killer):
	if killer is Ship:
		Events.score.emit(1, killer, global_position) # FIXME choose if this is actually the default scoring, or if killing does not generally score points
