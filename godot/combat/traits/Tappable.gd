extends Trait

func validate():
	.validate()
	assert(host.has_method('_on_tap')) # (author)
	
