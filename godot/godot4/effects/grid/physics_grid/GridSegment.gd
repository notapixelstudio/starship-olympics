extends DampedSpringJoint2D

func _process(delta: float) -> void:
	$Line2D.set_point_position(0, get_node(node_a).position)
	$Line2D.set_point_position(1, get_node(node_b).position)
