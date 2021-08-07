extends Trait

var host_parent = null

func validate():
	.validate()
	assert(host.has_method('place_and_push')) # needed to conserve position and linear velocity of its dropper
	
func _ready():
	host_parent = host.get_parent()
	
func remove():
	host_parent.remove_child(host)
	
func restore():
	host_parent.call_deferred('add_child', host) # defer to avoid considering the holdable again for loading during this frame
