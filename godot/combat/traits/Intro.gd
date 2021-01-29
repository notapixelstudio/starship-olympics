extends Trait

func validate():
	.validate()
	assert(host.has_method('intro')) # ()
	assert(host.has_signal('done')) # (self)
	
