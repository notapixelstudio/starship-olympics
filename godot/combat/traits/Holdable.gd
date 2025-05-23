extends Trait

var host_parent = null

func validate():
	super.validate()
	assert(host.has_method('place_and_push')) # needed to conserve position and linear velocity of its dropper
	assert(host.has_method('get_texture'))
	assert(host.has_method('show_on_top'))
	assert(host.has_method('is_rotatable'))
	assert(host.has_method('is_glowing'))
	assert(host.has_method('is_loadable'))
	assert(host.has_method('has_type'))
	assert(host.has_method('is_equivalent_to'))
	
func _ready():
	host_parent = host.get_parent()
	
func remove():
	if host_parent.is_ancestor_of(host):
		host_parent.remove_child(host)
	
func restore():
	if not host_parent.is_ancestor_of(host):
		host_parent.call_deferred('add_child', host) # defer to avoid considering the holdable again for loading during this frame
	
