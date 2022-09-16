extends Trait

func validate():
	super.validate()
	assert(host.has_method('get_global_endpoints')) # -> Dictionary {start: Vector2, end: Vector2}
