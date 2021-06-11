extends Position2D

class_name TargetDest

export var node_owner_path : NodePath = @".."

var node_owner

func _ready():
	while not node_owner:
		node_owner = get_node(node_owner_path)
	
func get_master_ship():
	return node_owner

func _process(_delta):
	position.x = (node_owner.velocity).length()/2

func get_strategy(ship, distance, game_mode):
	var calling_ship_team = ship.info_player.team
	var this_ship_team = get_master_ship().info_player.team
	
	if game_mode.name == 'Deathmatch':
		# pursue ships of opposing teams
		if calling_ship_team != this_ship_team:
			return {'seek': distance/2000, 'shoot': 0.5}
	elif game_mode.name == 'Take the Crown' or game_mode.name == 'Slam-a-Gon' or game_mode.name == 'Queen of the Hive':
		# if you have the Crown/Ball, turn away from foes and shoot
		#if ECM.E(ship).has('Royal'):
		#	return {'shoot': 0.5}
		# if I have the Crown/Ball, try to touch me
		if ECM.E(get_master_ship()).has('Royal'):
			return {'seek': 10, 'shoot': 7000/max(distance,0.1)}
		# ignore me - the Crown/Ball is somewhere onto the battlefield
		else:
			return {}
	elif game_mode.name == 'Pong':
		return {'shoot': 10}
	elif game_mode.get_id() == 'king_of_the_castle':
		# pursue ships of opposing teams and keep close
		if calling_ship_team != this_ship_team:
			return {'seek': distance/500, 'shoot': 0.5}
	elif game_mode.get_id() == 'bumper_ships':
		# pursue ships of opposing teams, having fewer points
		if calling_ship_team != this_ship_team:
			return {'seek': distance}
		
	# default: shoot at ships of opposing teams, sometimes
	if calling_ship_team != this_ship_team:
		return {'seek': distance/2000, 'shoot': 0.5}
		
	return {}
