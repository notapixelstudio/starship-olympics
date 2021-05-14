extends PinJoint2D

onready var ship = get_node(node_a)
var hook_position

func _process(_delta):
	if not ship or not hook_position:
		return
		
	$Line2D.points = PoolVector2Array([hook_position, ship.global_position])
	rotation = -get_parent().rotation
	$Line2D.position = -global_position

func set_path(path):
	node_b = path
	hook_position = ship.global_position
	
func release():
	node_b = ''
	$Line2D.points = PoolVector2Array([])
	hook_position = null
