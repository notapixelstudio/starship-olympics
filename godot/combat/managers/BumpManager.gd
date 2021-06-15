extends Node

const BASE_SPEED = 500
const SPEED_MULTIPLIER = 1.5

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
	
	ship.emit_signal('bump')
	other.emit_signal('bump')
	global.arena.show_ripple((ship.position+other.position)/2, 2)
	$RandomAudioStreamPlayer.play()
	yield(get_tree(), "idle_frame")
	ship.linear_velocity = ship.linear_velocity.normalized() * (BASE_SPEED + SPEED_MULTIPLIER*ship.linear_velocity.length())
	other.linear_velocity = other.linear_velocity.normalized() * (BASE_SPEED + SPEED_MULTIPLIER*other.linear_velocity.length())
	
