extends Line2D

# The target node to track
var nodeA: Node2D
var nodeB: Node2D 

# The NodePath to the target



func _process(delta):
	print(points)
	if nodeA and nodeB:
		
		points = PoolVector2Array([nodeA.global_position, nodeB.global_position])
	
