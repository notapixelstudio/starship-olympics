extends Manager

# WARNING this implementation works only if a field never changes components while an object is inside it
# FIXME need to switch to a continuous check + timeout

func _on_sth_entered(sth, other):
	var sth_entity = ECM.E(sth)
	var other_entity = ECM.E(other)
	
	if not sth_entity or not other_entity:
		return
		
	if sth_entity.has('Fluid') and other_entity.has('Thrusters'):
		other_entity.get_node('Thrusters').disable()
		
func _on_sth_exited(sth, other):
	var sth_entity = ECM.E(sth)
	var other_entity = ECM.E(other)
	
	if not sth_entity or not other_entity:
		return
		
	if sth_entity.has('Fluid') and other_entity.could_have('Thrusters'):
		other_entity.get_node('Thrusters').enable()
		
# FIXME to be removed
func _on_Ice_entered(ice, other):
	var entity = ECM.E(other)
	
	if not entity:
		return
		
	if entity.has('Thrusters'):
		entity.get_node('Thrusters').disable()
	
func _on_Ice_exited(ice, other):
	var entity = ECM.E(other)
	
	if not entity:
		return
		
	if entity.could_have('Thrusters'):
		entity.get_node('Thrusters').enable()
		