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
	
func get_appear_texture() -> Texture:
	return %Sprite2D.texture
