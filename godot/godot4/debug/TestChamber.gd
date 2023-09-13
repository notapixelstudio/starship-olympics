extends Node2D

var test_subject : Node2D : set = set_test_subject

func set_test_subject(v : Node2D) -> void:
	test_subject = v

func _process(delta):
	if not test_subject:
		return
		
