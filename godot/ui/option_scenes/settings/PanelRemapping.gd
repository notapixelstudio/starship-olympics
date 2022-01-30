extends UIOptionPanel

export var what_to_remap_scene: PackedScene
 
func setup_device(args: String):
	content.setup_device(args)

func _ready():
	Events.connect("ask_mapping_action", self, "show_remap_scene")
	
func show_remap_scene(action: String):
	var remap = what_to_remap_scene.instance()
	remap.action = action
	add_child(remap)
