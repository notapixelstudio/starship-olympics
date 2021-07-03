extends Trait

func validate():
	.validate()
	assert(host is RigidBody2D)
	assert(host.has_signal('bump'))
	assert(host.contact_monitor)
	assert(host.contacts_reported > 0)
	
