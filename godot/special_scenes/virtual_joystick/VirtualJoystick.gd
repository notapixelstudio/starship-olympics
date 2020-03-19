extends Node2D


onready var fire_btn: TouchScreenButton = get_node("Buttons/FireButton")
onready var wheel: JoyStickWheel = get_node("Wheel/TouchScreenButton") 


func _ready() -> void:
	pass # Replace with function body.


#func _process(delta: float) -> void:
#	pass

func is_action_pressed(action_name: String) -> bool:
	match action_name:
		"fire":
			return fire_btn.is_pressed()
		_:
			return wheel.is_action_pressed(action_name)

# TODO Implement these functions
func is_action_just_press(action_name: String) -> bool:
	match action_name:
		"fire":
			return fire_btn.is_pressed()
		_:
			return wheel.is_action_pressed(action_name)

func is_action_just_release(action_name: String) -> bool:
	match action_name:
		"fire":
			return fire_btn.is_pressed()
		_:
			return wheel.is_action_pressed(action_name)
