class_name ConstantForceMovement extends Trait2D
## Applies directional force to a RigidBody2D host.

func validate():
	super.validate()
	assert(host is RigidBody2D)

func move(direction: float, force: float) -> void:
	(get_host() as RigidBody2D).set_constant_force(force * Vector2.RIGHT.rotated(direction))
