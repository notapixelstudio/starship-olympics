class_name TestChamber
extends Node2D

@export var test_player : Player
@export var player_brain_scene : PackedScene
var test_subject : Node2D : set = set_test_subject

func set_test_subject(v : Node2D) -> void:
	test_subject = v
	
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# default test subject is a node named Ship, accessible via local unique names
	if get_node_or_null('%Ship'):
		set_test_subject(%Ship)
		%Ship.set_player(test_player)
		var brain = player_brain_scene.instantiate()
		brain.set_controls(test_player.get_controls())
		%Ship.add_child(brain)
		Events.team_ready.emit(test_player.get_team(), [test_player])
		
func _process(delta):
	if not test_subject:
		return
		
func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_restart_scene"):
		get_tree().reload_current_scene()
