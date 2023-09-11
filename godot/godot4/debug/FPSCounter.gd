extends Node2D

func _process(delta):
	$Count.set_text("%d" % Engine.get_frames_per_second())
