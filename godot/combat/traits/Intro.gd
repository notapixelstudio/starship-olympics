extends Trait

@export var order = 0

func validate():
	super.validate()
	assert(host.has_method('intro')) # ()
	assert(host.has_signal('done')) # (self) # TODO: better be called intro_done. name it's confusing
	
