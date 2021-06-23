extends Node

const BASE_SPEED = 500
const SPEED_MULTIPLIER = 1.5

func start():
	# listen to all bumpers
	for bumper in traits.get_all_with('Bumper'):
		bumper.connect('body_entered', self, '_on_bumper_collided', [bumper])
		
func _on_bumper_collided(bumper_b, bumper_a):
	assert(traits.has_trait(bumper_a, 'Bumper'))
	if not(traits.has_trait(bumper_b, 'Bumper')):
		return
	
	# avoid checking bump twice per collision
	if bumper_a.get_instance_id() < bumper_b.get_instance_id():
		return
	
	bumper_a.emit_signal('bump')
	bumper_b.emit_signal('bump')
	global.arena.show_ripple((bumper_a.position+bumper_b.position)/2, 2)
	$RandomAudioStreamPlayer.play()
	yield(get_tree(), "idle_frame")
	bumper_a.linear_velocity = bumper_a.linear_velocity.normalized() * (BASE_SPEED + SPEED_MULTIPLIER*bumper_a.linear_velocity.length())
	bumper_b.linear_velocity = bumper_b.linear_velocity.normalized() * (BASE_SPEED + SPEED_MULTIPLIER*bumper_b.linear_velocity.length())
	
