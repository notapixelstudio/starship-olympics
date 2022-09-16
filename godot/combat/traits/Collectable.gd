extends Trait

func validate():
	super.validate()
	assert(host.has_method('collect')) # (by)
	assert(host.has_signal('collected')) # (by)
	
