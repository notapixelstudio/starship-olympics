extends Trait

func validate():
	.validate()
	assert(host.has_method('time_freeze'))
	assert(host.has_method('time_unfreeze'))
	
