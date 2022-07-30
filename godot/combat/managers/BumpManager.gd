extends Node

const BASE_SPEED = 0
const SPEED_MULTIPLIER = 2.0

func _enter_tree():
	# listen to newly created bumpers
	Events.connect('bumper_created', self, 'register_bumper')
	
func _exit_tree():
	# stop listening when outside tree
	Events.disconnect('bumper_created', self, 'register_bumper')
	
func register_bumper(bumper):
	bumper.connect('body_entered', self, '_on_bumper_collided', [bumper])
	
func _on_bumper_collided(bumper_b, bumper_a):
	# only two bumpers should bump
	if not traits.has_trait(bumper_a, 'Bumper') or not traits.has_trait(bumper_b, 'Bumper'):
		return
	
	# avoid checking bump twice per collision
	if bumper_a.get_instance_id() < bumper_b.get_instance_id():
		return
	
	bumper_a.emit_signal('bump')
	bumper_b.emit_signal('bump')
	Events.emit_signal("sths_bumped", bumper_a, bumper_b)
	global.arena.show_ripple((bumper_a.global_position+bumper_b.global_position)/2, 2)
	$RandomAudioStreamPlayer.play()
	yield(get_tree(), "idle_frame")
	
	if is_instance_valid(bumper_a):
		var speed_multiplier = SPEED_MULTIPLIER
		if bumper_a is Ship and bumper_a.is_on_ice():
			speed_multiplier = 1.2
		bumper_a.linear_velocity = bumper_a.linear_velocity.normalized() * (BASE_SPEED + speed_multiplier*bumper_a.linear_velocity.length()) / bumper_a.mass
	
	if is_instance_valid(bumper_b):
		var speed_multiplier = SPEED_MULTIPLIER
		if bumper_b is Ship and bumper_b.is_on_ice():
			speed_multiplier = 1.2
		bumper_b.linear_velocity = bumper_b.linear_velocity.normalized() * (BASE_SPEED + speed_multiplier*bumper_b.linear_velocity.length()) / bumper_b.mass
	
