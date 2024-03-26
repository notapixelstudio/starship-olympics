extends Trait

func validate():
	super.validate()
	assert(host.has_method('get_score')) # ()
	
