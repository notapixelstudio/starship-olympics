extends RigidBody2D

class_name Mine

var owner_ship

signal bump

func set_owner_ship(v):
	owner_ship = v
	
func get_owner_ship():
	return owner_ship

func _ready():
	# FIXME? this could be enforced by the trait
	Events.emit_signal('bumper_created', self)

func make_solid():
	set_collision_mask_bit(0, true)

func detonate():
	if $AnimationPlayer.current_animation != 'Detonate':
		$AnimationPlayer.play("Detonate")

func explode():
	for body in $Area2D.get_overlapping_bodies():
		if body.has_method('die'):
			body.apply_central_impulse(500*(global_position-body.global_position).normalized())
			body.die(self.get_owner_ship())
	
