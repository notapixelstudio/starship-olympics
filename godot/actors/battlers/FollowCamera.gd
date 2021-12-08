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
	
func _physics_process(delta):
	if is_instance_valid(self) and self.is_inside_tree() and is_instance_valid(node_owner) and node_owner.is_inside_tree():
		var space_state = get_world_2d().direct_space_state
		var where = node_owner.global_position
		var result = space_state.intersect_ray(position, where, [self, node_owner], pow(2,7), true, true)
		if result:
			where = result.position
		global_position = lerp(global_position, where, delta*SPEED)
