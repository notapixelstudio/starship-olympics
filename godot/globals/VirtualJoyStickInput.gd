extends Node


onready var joystick_scene = preload("res://special_scenes/virtual_joystick/VirtualJoystick.tscn")
var virtual_joystick
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	virtual_joystick = joystick_scene.instance()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func add_joy_stick():
	# TODO add virtual joystick to keyboard
	var canvas_layer = CanvasLayer.new()
	canvas_layer.add_child(virtual_joystick)
	get_tree().get_current_scene().add_child(canvas_layer)

func is_action_pressed(action_name: String) -> bool:
	return virtual_joystick.is_action_pressed(action_name)

func is_action_just_press(action_name: String) -> bool:
	return virtual_joystick.is_action_pressed(action_name)

func is_action_just_release(action_name: String) -> bool:
	return virtual_joystick.is_action_pressed(action_name)
