class_name TestChamber
extends Node2D

var test_subject : Node2D : set = set_test_subject

func set_test_subject(v : Node2D) -> void:
	test_subject = v
	
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _process(delta):
	if not test_subject:
		return
		
func _on_control_selector_item_selected(index):
	if not test_subject or not test_subject is Ship or not test_subject.has_node('PlayerBrain'):
		return
		
	test_subject.get_node('PlayerBrain').set_controls('kb1' if index == 0 else 'joy1')
	%ControlSelector.release_focus()
