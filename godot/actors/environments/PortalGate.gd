tool
extends Gate
class_name PortalGate

export var linked_to_path : NodePath

func _on_PortalGate_crossed(sth, _self):
	var destination = get_node(linked_to_path)
	if destination == null:
		return
		
	var vector = sth.global_position - global_position
	sth.global_position = destination.global_position + vector
	
	assert(traits.has_trait(sth, 'Tracked'))
	traits.get_trait(sth, 'Tracked').reset()
