extends Trait

func validate():
	super.validate()
	assert(host.has_signal('collect'))
	
