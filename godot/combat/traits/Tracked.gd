extends Trait

func validate():
	.validate()
	assert(host.has_method('get_previous_global_position'))
	
