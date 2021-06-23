extends Trait

func validate():
	.validate()
	assert(host is RigidBody2D)
	assert(host.has_signal('bump'))
	
