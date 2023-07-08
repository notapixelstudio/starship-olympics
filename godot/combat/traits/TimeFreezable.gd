extends Trait

func validate():
	super.validate()
	assert(host.has_method('time_freeze'))
	assert(host.has_method('time_unfreeze'))
	
