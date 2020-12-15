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

func get_strategy(ship, distance, game_mode):
	var calling_ship_team = ship.info_player.team
	var this_ship_team = get_master_ship().info_player.team
	
	if game_mode.name == 'Deathmatch':
		# pursue ships of opposing teams
		if calling_ship_team != this_ship_team:
			return {'seek': distance/2000, 'shoot': 0.5}
		
	# shoot at ships of opposing teams, sometimes
	if calling_ship_team != this_ship_team:
		return {'seek': distance/2000, 'shoot': 0.5}
		
	return {}
