extends Node

const MIN_REL_VELOCITY = 175
const IMPULSE_MULTIPLIER = 0.8

func start():
	# listen to all ships
	for ship in get_tree().get_nodes_in_group('player_ship'):
		ship.connect('body_entered', self, '_on_ship_collided', [ship])
		
func _on_ship_collided(other, ship):
	assert(ship is Ship)
	if not(other is Ship):
		return
	
	# avoid checking bump twice per collision
	if ship.get_id() < other.get_id():
		return
	
	# bump is good if there's enough speed involved
	var relative_velocity = (ship.linear_velocity - other.linear_velocity)
	if relative_velocity.length() < MIN_REL_VELOCITY:
		return
	
	ship.emit_signal('bump')
	ship.apply_central_impulse(relative_velocity*IMPULSE_MULTIPLIER)
	other.emit_signal('bump')
	other.apply_central_impulse(-relative_velocity*IMPULSE_MULTIPLIER)
	global.arena.show_ripple((ship.position+other.position)/2, 2)
	$RandomAudioStreamPlayer.play()
