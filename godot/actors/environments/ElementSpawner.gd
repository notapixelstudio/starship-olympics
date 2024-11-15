@tool

extends Node2D
class_name ElementSpawner

@export var element_scene: PackedScene: set = set_element_scene
@export var preview_sprite_name := "Sprite2D"

const JITTER = 0.1

func set_element_scene(v: PackedScene):
	element_scene = v
	if not is_inside_tree():
		await self.ready
	refresh_preview()
	
func refresh_preview():
	# in editor, just use the element's sprite texture instead of the actual element
	if Engine.is_editor_hint():
		var element = element_scene.instantiate()
		$PreviewSprite.texture = element.get_node(preview_sprite_name).texture
		$PreviewSprite.scale = element.get_node(preview_sprite_name).scale
		element.queue_free()
	else:
		$PreviewSprite.queue_free()
		
func spawn(parent_node = null):
	if parent_node == null:
		parent_node = get_parent()
	var element = element_scene.instantiate()
	var where_to_spawn = global_position + Vector2(randfn(0.0,JITTER),randfn(0.0,JITTER))
	
	if element.has_method('create_appear_effect'): # WARNING duck typing, sort of
		var appear = element.create_appear_effect()
		appear.global_position = where_to_spawn
		parent_node.add_child(appear)
		await appear.done
		
	element.global_position = where_to_spawn
	parent_node.add_child(element)
	
	if traits.has_trait(element, 'Waiter'):
		element.start()
	
func remove_child(element):
	super.remove_child(element)
	element.queue_free()
