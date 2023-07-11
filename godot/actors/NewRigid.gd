extends RigidBody2D


func get_brain() -> Brain:
	if not has_node('Brain'):
		return null
	return ($Brain as Brain)

func set_brain(new_brain: Brain) -> void:
	var old_brain = get_brain()
	if old_brain != null:
		old_brain.disconnect('charge', Callable(self, '_on_charge_requested'))
		old_brain.disconnect('release', Callable(self, '_on_release_requested'))
		old_brain.free()
	new_brain.set_name('Brain')
	new_brain.connect('charge', Callable(self, '_on_charge_requested'))
	new_brain.connect('release', Callable(self, '_on_release_requested'))
	add_child(new_brain)

