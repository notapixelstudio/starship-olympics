class_name ConstantForceMovement extends ActorBehavior
## Applies directional force to a RigidBody2D actor.

func move(direction: float, force: float) -> void:
	var body := actor as RigidBody2D
	if body == null:
		body = get_parent() as RigidBody2D
	if body != null:
		body.set_constant_force(force * Vector2.RIGHT.rotated(direction))
