extends Node


onready var joystick_scene = preload("res://special_scenes/virtual_joystick/VirtualJoystick.tscn")
# TODO free virtual joystick
var virtual_joystick
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func add_joy_stick(show_wheel = true, show_buttons = true):
	# TODO add virtual joystick to keyboard
	var canvas_layer = CanvasLayer.new()
	virtual_joystick = joystick_scene.instance()
	
	canvas_layer.add_child(virtual_joystick)
	get_tree().get_current_scene().add_child(canvas_layer)
	virtual_joystick.show(show_wheel, show_buttons)

func is_action_pressed(action_name: String) -> bool:
	return virtual_joystick != null and virtual_joystick.is_action_pressed(action_name)

func is_action_just_press(action_name: String) -> bool:
	return virtual_joystick != null and virtual_joystick.is_action_pressed(action_name)

func is_action_just_release(action_name: String) -> bool:
	return virtual_joystick != null and virtual_joystick.is_action_pressed(action_name)
