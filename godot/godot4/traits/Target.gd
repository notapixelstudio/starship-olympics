extends Trait

func validate():
	super.validate()
	assert(host is Node2D)
	assert(host.has_method('get_team'))
