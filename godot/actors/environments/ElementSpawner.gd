@tool

extends Node2D
class_name ElementSpawner

@export var element_scene: PackedScene :
	get:
		return element_scene # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_element_scene
@export var preview_sprite_name := "Sprite2D"

func set_element_scene(v: PackedScene):
	element_scene = v
	if not is_inside_tree():
		await self.ready
	refresh_preview()
	
func refresh_preview():
	# in editor, just use the element's sprite texture instead of the actual element
	var element = element_scene.instantiate()
	if Engine.is_editor_hint():
		$PreviewSprite.texture = element.get_node(preview_sprite_name).texture
		$PreviewSprite.scale = element.get_node(preview_sprite_name).scale
	else:
		$PreviewSprite.queue_free()
	element.queue_free()
		
func spawn():
	var element = element_scene.instantiate()
	add_child(element)
	
func remove_child(element):
	super.remove_child(element)
	element.queue_free()
