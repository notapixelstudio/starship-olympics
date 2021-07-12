extends Control

class_name UIOptionPanel

export (String, "normal", "large") var panel_type = "normal"
onready var title = $Title
onready var content = $Content
onready var back_button = $Back

func _ready():
	add_to_group("UIOptionPanel")
	assert(title)
	assert(content)
	assert(back_button)

func set_content(instanced_scene: Node):
	for child in content.get_children():
		content.remove_child(child)
	
	content.add_child(instanced_scene)


func _on_Back_pressed():
	pass # Replace with function body.
