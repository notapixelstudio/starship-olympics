extends Node2D

func _process(delta):
	$Wrapper.rotation = -global_rotation
