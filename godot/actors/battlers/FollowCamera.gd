extends Position2D

export var node_owner_path : NodePath = @".."

const SPEED = 4
var node_owner

func _ready():
	while not node_owner:
		node_owner = get_node(node_owner_path)
	
func get_master_ship():
	return node_owner

func ship_just_died(ship, killer, for_good):
	if ship.info_player.lives== 0:
		remove_from_group("in_camera")
		queue_free()
		
	if for_good:
		queue_free()
	
func _process(delta):
	if is_inside_tree() and node_owner.is_inside_tree():
		global_position = lerp(global_position, node_owner.global_position, delta*SPEED)
