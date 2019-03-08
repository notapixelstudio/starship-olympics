extends Manager

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
		