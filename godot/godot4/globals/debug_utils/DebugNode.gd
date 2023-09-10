extends Hosted

class_name DebugNode

## returns whether the given scene has been run as standalone
func is_host_standalone() -> bool:
	assert(host != null)
	return self.host.get_parent() == get_tree().root

## applies the default camera
func apply_default_camera() -> void:
	var camera = Camera2D.new()
	camera.zoom = Vector2(0.2, 0.2)
	self.host.get_parent().add_child.call_deferred(camera)
	
	
