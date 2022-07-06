extends Trait

func validate():
	.validate()
	assert(host.has_method('get_global_polygon')) # -> PoolVector2Array
