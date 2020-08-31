extends Node2D

class_name Ripple


func _on_animation_ended(name):
	get_parent().call_deferred("remove_child", self)
	yield(get_tree().create_timer(1), "timeout")
	call_deferred("queue_free")
	
