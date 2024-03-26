extends Trait

func validate():
	super.validate()
	assert(host.has_method('get_score'))
	assert(host.has_signal('conquered'))
	assert(host.has_signal('lost'))
	
