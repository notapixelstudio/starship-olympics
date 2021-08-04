extends Node

const BASE_SPEED = 500
const SPEED_MULTIPLIER = 1.5

func start():
	# listen to bumpers already in place
	#for bumper in traits.get_all_with('Bumper'):
	#	register_bumper(bumper)
	
	# listen to newly created bumpers
	Events.connect('bumper_created', self, 'register_bumper')
	
func register_bumper(bumper):
	bumper.connect('body_entered', self, '_on_bumper_collided', [bumper])
	
func _on_bumper_collided(bumper_b, bumper_a):
	if not is_inside_tree():
		return # FIXME this is beacuse we continue to listen bumpers with the bump manager of the map!
	
	assert(traits.has_trait(bumper_a, 'Bumper'))
	assert(traits.has_trait(bumper_b, 'Bumper'))
	
	# avoid checking bump twice per collision
	if bumper_a.get_instance_id() < bumper_b.get_instance_id():
		return
	
	bumper_a.emit_signal('bump')
	bumper_b.emit_signal('bump')
	global.arena.show_ripple((bumper_a.global_position+bumper_b.global_position)/2, 2)
	$RandomAudioStreamPlayer.play()
	yield(get_tree(), "idle_frame")
	
	if is_instance_valid(bumper_a):
		bumper_a.linear_velocity = bumper_a.linear_velocity.normalized() * (BASE_SPEED + SPEED_MULTIPLIER*bumper_a.linear_velocity.length()) / bumper_a.mass
	
	if is_instance_valid(bumper_b):
		bumper_b.linear_velocity = bumper_b.linear_velocity.normalized() * (BASE_SPEED + SPEED_MULTIPLIER*bumper_b.linear_velocity.length()) / bumper_b.mass
	
