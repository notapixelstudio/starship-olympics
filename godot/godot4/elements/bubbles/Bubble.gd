extends RigidBody2D
class_name Bubble

@export var content_scene : PackedScene : set = set_content_scene
@export var bubble_popped_scene : PackedScene
@export var appear_scene : PackedScene

var _content
var _bumps := 0

func set_content_scene(v:PackedScene) -> void:
	content_scene = v
	_content = content_scene.instantiate()
	%ContentSprite2D.texture = _content.get_texture() # FIXME strong assumption

func _on_area_2d_body_entered(body):
	if body is Ship:
		if body.is_dashing():
			if _content:
				_content.global_position = global_position
				get_parent().add_child.call_deferred(_content)
				_content.touched_by.call_deferred(body) # FIXME strong assumption
			SoundEffects.play(%PopSFX)
			var pop = bubble_popped_scene.instantiate()
			pop.global_position = global_position
			get_parent().add_child(pop)
			queue_free()
		else:
			_bumps += 1
			%Label.visible = _bumps >= 3
			SoundEffects.play(%BounceSFX)
			apply_central_impulse(max(6,body.linear_velocity.length()/120.0)*(global_position-body.global_position))
	
func _on_body_entered(body):
	if body is Ship:
		return
		
	if body is Bubble and get_rid() <= body.get_rid():
		return
		
	SoundEffects.play(%BounceSFX)

func create_appear_effect() -> Node2D:
	return appear_scene.instantiate()
	
