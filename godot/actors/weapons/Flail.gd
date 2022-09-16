extends Node2D

@export var hook_to : NodePath :
	get:
		return hook_to # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_hook_to

func set_hook_to(v):
	hook_to = v
	$LastPinJoint.node_b = hook_to
	var node = get_node(hook_to)
	if node.has_method('get_color'):
		$Ball.modulate = node.get_color()
	
	
func _draw():
	var points = []
	for child in get_children():
		if child is RigidBody2D:
			points.append(to_local(child.global_position))
			
	draw_polyline(PackedVector2Array(points), Color(1.2,1.2,1.2), 8.0, true)
