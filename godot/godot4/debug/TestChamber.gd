class_name TestChamber
extends Node2D

@export var test_player : Player
@export var player_brain_scene : PackedScene
var test_subject : Node2D : set = set_test_subject

func set_test_subject(v : Node2D) -> void:
	test_subject = v
	
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# default test subject is the first ship found in group Ships
	var ships = get_tree().get_nodes_in_group("Ship")
	if len(ships) > 0:
		set_test_subject(ships[0])
		ships[0].set_player(test_player)
		
	for ship in ships:
		#var brain = player_brain_scene.instantiate()
		#brain.set_controls(ship.get_player().get_controls())
		#ship.add_child(brain)
		Events.team_ready.emit(ship.get_player().get_team(), [ship.get_player()])
		
func _process(delta):
	if not test_subject:
		return
		
func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_restart_scene"):
		get_tree().reload_current_scene()
