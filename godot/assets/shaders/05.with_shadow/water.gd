@tool
extends Sprite2D

func _ready():
	update_shader_aspect_ratio()

func _on_item_rect_changed():
	update_shader_aspect_ratio()

func update_shader_aspect_ratio():
	material.set_shader_parameter("aspect_ratio", scale.y/scale.x)