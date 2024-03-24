class_name TestChamber
extends Node2D

var test_subject : Node2D : set = set_test_subject

func set_test_subject(v : Node2D) -> void:
	test_subject = v
	
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# default test subject is a node named Ship, accessible via local unique names
	if get_node_or_null('%Ship'):
		set_test_subject(%Ship)
		var fake_player = Player.new()
		%Ship.set_player(fake_player)

func _process(delta):
	if not test_subject:
		return
		
func _on_control_selector_item_selected(index):
	if not test_subject or not test_subject is Ship or not test_subject.has_node('PlayerBrain'):
		return
		
	test_subject.get_node('PlayerBrain').set_controls('kb1' if index == 0 else 'joy1')
	%ControlSelector.release_focus()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_restart_scene"):
		get_tree().reload_current_scene()
