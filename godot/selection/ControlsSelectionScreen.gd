extends Sprite

export var controls : String setget _set_controls

var commands = ["right", "down", "up", "left", "fire"]
var pp = {
	"left": "←",
	"up":"↑",
	"down":"↓",
	"right":"→"
	}

func _set_controls(value_):
	controls = value_
	for action in commands:
		get_node(action).visible = false
		if "kb" in controls:
			var event = InputMap.get_action_list(controls+"_"+action)
			var keyboard = OS.get_scancode_string(event[0].scancode).to_lower()
			if keyboard in pp:
				keyboard = pp[keyboard]
			get_node(action).text = keyboard
			get_node(action).visible = true
