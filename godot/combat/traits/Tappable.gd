extends Trait

func validate():
	super.validate()
	assert(host.has_method('tap')) # (author)
	assert(host.has_method('show_tap_preview'))
	assert(host.has_method('hide_tap_preview'))
