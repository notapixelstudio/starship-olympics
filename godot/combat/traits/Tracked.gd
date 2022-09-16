extends Trait

func validate():
	super.validate()
	assert(host.has_method('get_previous_global_position'))
	
