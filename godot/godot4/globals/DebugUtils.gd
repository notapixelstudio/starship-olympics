extends Node

@export var test_ship_brain : PackedScene

## returns whether the given scene has been run as standalone
func is_scene_standalone(scene : Node) -> bool:
	return scene.get_parent() == get_tree().root

## applies the default camera to the given node, in order to test it
func apply_default_camera_to_node(node : Node) -> void:
	var camera = Camera2D.new()
	camera.zoom = Vector2(0.2, 0.2)
	node.get_parent().add_child.call_deferred(camera)
	
func get_default_ship_brain() -> Brain:
	return test_ship_brain.instantiate()
	
