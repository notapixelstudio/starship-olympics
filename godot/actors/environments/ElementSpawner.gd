tool

extends Node2D
class_name ElementSpawner

export var element_scene: PackedScene setget set_element_scene
export var preview_sprite_name := "Sprite"

func set_element_scene(v: PackedScene):
	element_scene = v
	if not is_inside_tree():
		yield(self, "ready")
	refresh_preview()
	
func refresh_preview():
	# in editor, just use the element's sprite texture instead of the actual element
	var element = element_scene.instance()
	if Engine.is_editor_hint():
		$PreviewSprite.texture = element.get_node(preview_sprite_name).texture
		$PreviewSprite.scale = element.get_node(preview_sprite_name).scale
	else:
		$PreviewSprite.queue_free()
	element.queue_free()
		
func spawn():
	var element = element_scene.instance()
	add_child(element)
	
func remove_child(element):
	.remove_child(element)
	element.queue_free()
