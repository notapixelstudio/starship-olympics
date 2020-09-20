extends Position2D

class_name TargetDest
export var node_owner_path : NodePath = @".."

var node_owner

func _ready():
	while not node_owner:
		node_owner = get_node(node_owner_path)
	
func get_master_ship():
	return node_owner

func _process(delta):
	position.x = (node_owner.velocity).length()/2
