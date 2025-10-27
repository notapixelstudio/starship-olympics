extends RigidBody2D
class_name Bubble

@export var content_scene : PackedScene : set = set_content_scene
@export var bubble_popped_scene : PackedScene
@export var appear_scene : PackedScene

var _content
var _bumps := 0

func set_content_scene(v:PackedScene) -> void:
	content_scene = v
	if content_scene:
		set_content(content_scene.instantiate())
	
func set_content(v) -> void:
	if _content:
		return
		
	_content = v
	%ContentSprite2D.texture = _content.get_texture() # FIXME strong assumption
	
func pop(author=null) -> void:
	if _content and is_instance_valid(_content) and not _content.is_queued_for_deletion():
		release_content(author)
		_content = null
	SoundEffects.play(%PopSFX)
	var pop = bubble_popped_scene.instantiate()
	pop.global_position = global_position
	Events.spawn_request.emit(pop)
	queue_free()
	
func release_content(author) -> void:
	_content.global_position = global_position
	Events.spawn_request.emit(_content)
	
	# released content is always considered touched by the author, if any
	if author != null:
		# trigger a fake high-level touch collision
		Events.collision.emit.call_deferred(author, _content, 'touch')
	
func _on_area_2d_body_entered(body):
	if body is Ship:
		if body.is_dashing():
			pop(body)
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
	var appear = appear_scene.instantiate()
	if _content.has_method('get_appear_texture'): # WARNING duck typing
		appear.set_texture(_content.get_appear_texture())
	return appear

func set_content_rotation(v:float) -> void:
	%ContentSprite2D.rotation = v
