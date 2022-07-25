tool

extends Node2D
class_name ElementSpawner

export var element_scene: PackedScene
export var preview_sprite_name := "Sprite"

func _ready():
	# in editor, just use the element's sprite texture instead of the actual element
	var element = element_scene.instance()
	if Engine.is_editor_hint():
		$PreviewSprite.texture = element.get_node(preview_sprite_name).texture
	else:
		$PreviewSprite.queue_free()
		
func spawn():
	var element = element_scene.instance()
	add_child(element)
	
func remove_child(element):
	.remove_child(element)
	element.queue_free()
