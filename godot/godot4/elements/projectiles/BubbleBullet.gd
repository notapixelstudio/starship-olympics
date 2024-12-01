extends RigidBody2D
class_name BubbleBullet

@export var bubble_scene : PackedScene

func hurt(sth) -> void:
	if sth is Ship:
		var bubble = bubble_scene.instantiate()
		bubble.set_player(sth.get_player())
		bubble.global_position = sth.global_position
		sth.queue_free()
		get_parent().add_child.call_deferred(bubble)
		bubble.set_content_rotation(sth.global_rotation)
		queue_free()
