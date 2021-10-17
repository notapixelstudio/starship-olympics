extends Trait

func validate():
	.validate()
	assert(host.has_method('detonate'))
	assert(host.has_method('get_owner_ship'))
