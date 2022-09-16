extends Trait

func validate():
	super.validate()
	assert(host.has_method('get_global_polygon')) # -> PackedVector2Array
