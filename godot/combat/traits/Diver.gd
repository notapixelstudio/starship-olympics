extends Trait

func validate():
	.validate()
	assert(host.has_method('dive'))
	assert(host.has_method('set_dive_speed'))
	
