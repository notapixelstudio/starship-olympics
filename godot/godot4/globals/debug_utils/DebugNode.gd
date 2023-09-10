extends Node

class_name DebugNode

## hosted should explicit set the host attached to
@export var host: Node : get = get_host

func get_host() -> Node:
	return host 

func _ready():
	if not OS.is_debug_build():
		queue_free()
	if host == null:
		host = get_parent()

## returns whether the given scene has been run as standalone
func is_host_standalone() -> bool:
	assert(host != null)
	return self.host.get_parent() == get_tree().root

## applies the default camera
func apply_default_camera() -> void:
	var camera = Camera2D.new()
	camera.zoom = Vector2(0.2, 0.2)
	self.host.get_parent().add_child.call_deferred(camera)
	
	
