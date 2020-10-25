extends PinJoint2D

func _process(delta):
	var a = get_node(node_a)
	var b = get_node(node_b)
	var ap = a.global_position
	var bp = b.global_position
	var ar = a.radius*0.9
	var br = b.radius*0.9
	$Line2D.points = PoolVector2Array([ap + ar*(bp-ap).normalized(), bp + br*(ap-bp).normalized()])
	rotation = -get_parent().rotation
	$Line2D.position = -global_position
