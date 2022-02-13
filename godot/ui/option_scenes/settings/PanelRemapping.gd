extends UIOptionPanel

class_name PanelRemapping

export var what_to_remap_scene: PackedScene
 
func setup_device(device_category: String):
	content.setup_device(device_category)

func _ready():
	Events.connect("ask_mapping_action", self, "show_remap_scene")
	$Content/VBoxContainer/Device.grab_focus()
	
func show_remap_scene(action: String):
	var remap: AddingBindingControls = what_to_remap_scene.instance()
	remap.action = action
	add_child(remap)
