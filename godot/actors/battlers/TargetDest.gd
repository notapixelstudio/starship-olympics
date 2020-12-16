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
	elif game_mode.name == 'Take the Crown' or game_mode.name == 'Slam-a-Gon':
		# if you have the Crown/Ball, turn away from foes and shoot
		#if ECM.E(ship).has('Royal'):
		#	return {'shoot': 0.5}
		# if I have the Crown/Ball, try to touch me
		if ECM.E(get_master_ship()).has('Royal'):
			return {'seek': 10}
		# ignore me - the Crown/Ball is somewhere onto the battlefield
		else:
			return {}
		
	# default: shoot at ships of opposing teams, sometimes
	if calling_ship_team != this_ship_team:
		return {'seek': distance/2000, 'shoot': 0.5}
		
	return {}
