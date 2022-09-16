extends Trait

func validate():
	super.validate()
	assert(host.has_method('set_player')) # (InfoPlayer)
	assert(host.has_method('get_player')) # () -> InfoPlayer
	
