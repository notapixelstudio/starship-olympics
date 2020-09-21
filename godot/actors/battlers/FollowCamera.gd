extends Position2D

export var node_owner_path : NodePath = @".."

const SPEED = 4
var node_owner

func _ready():
	while not node_owner:
		node_owner = get_node(node_owner_path)
	
func get_master_ship():
	return node_owner

func _process(delta):
	global_position = lerp(global_position, node_owner.global_position, delta*SPEED)
