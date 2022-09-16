extends UIOptionPanel

class_name PanelRemapping

@export var what_to_remap_scene: PackedScene
#@export (String, "keyboard", "joypad", "custom") var device_category = "keyboard"
@export var device_category := "keyboard"
@onready var device_node = $Content/VBoxContainer/Device

var device

func setup_device(path: String):
	device_node.element_path = path
	device_node.setup()

func _ready():
	Events.connect("ask_mapping_action",Callable(self,"show_remap_scene"))
	Events.connect("remap_done",Callable(self,"update_mapping"))
	$Content/VBoxContainer/Device.grab_focus()
	self.setup_device(self.device_category + "_device")
	for child in get_tree().get_nodes_in_group("remapping_actions"):
		child.connect("clear_mapping",Callable(self,"clear_mapping"))
	
func show_remap_scene(action: String, remap_action_asker: RemapAction):
	var remap: RemappingScene = what_to_remap_scene.instantiate()
	remap.action = action
	remap.device_category = self.device_category
	$CanvasLayer.add_child(remap)
	remap.connect("remap_event",Callable(remap_action_asker,"on_remap"))
	set_process_input(false)

func update_mapping(remap_action_asker):
	set_process_input(true)
	remap_action_asker.grab_focus()
	

func _on_Device_value_changed(value):
	device = value
	if device == null:
		return
	if not is_inside_tree():
		await self.ready
	# we need to wait a frame in order to wait that everything will be available
	await get_tree().idle_frame
	for child in get_tree().get_nodes_in_group("remapping_actions"):
		if child.device != 'ui':
			child.visible = true
			child.device = value
			child.setup()
			
func _on_Default_pressed():
	var mapping = Controls.set_presets(device, "default")
	_on_Device_value_changed(device)

func clear_mapping(action: String):
	if not "joy" in action:
		return

func _on_Preset_value_changed(value):
	if value == null:
		return
	var mapping = Controls.set_presets(device, value)
	_on_Device_value_changed(device)
