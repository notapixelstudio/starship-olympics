extends Trait

func validate():
	super.validate()
	assert(host is RigidBody2D)
	assert(host.has_signal('bump'))
	assert(host.contact_monitor)
	assert(host.max_contacts_reported > 0)
	
func _ready():
	# wait for host
	await host.ready
	Events.emit_signal("bumper_created", host)
