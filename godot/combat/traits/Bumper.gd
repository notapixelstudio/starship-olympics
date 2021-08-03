extends Trait

func validate():
	.validate()
	assert(host is RigidBody2D)
	assert(host.has_signal('bump'))
	assert(host.contact_monitor)
	assert(host.contacts_reported > 0)
	
func _ready():
	# wait for host
	yield(host, "ready")
	Events.emit_signal("bumper_created", host)
