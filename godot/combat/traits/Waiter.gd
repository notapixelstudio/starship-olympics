extends Trait

func validate():
	.validate()
	assert(host.has_method('start'))
	
