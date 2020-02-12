extends Manager

# WARNING this implementation works only if a field never changes components while an object is inside it
# FIXME need to switch to a continuous check + timeout

signal repel_cargo
func _on_sth_entered(sth, other):
	var sth_entity = ECM.E(sth)
	var other_entity = ECM.E(other)
	
	if not sth_entity or not other_entity:
		return
		
		
	if sth_entity.has('Flow') and other_entity.could_have('Flowing'):
		other_entity.get_node('Flowing').set_flow(sth_entity.get_node('Flow'))
		other_entity.get_node('Flowing').enable()
		
	if sth_entity.has('CrownDropper') and other_entity.has('Cargo') and other_entity.get('Cargo').what is Crown:
		emit_signal('repel_cargo', other_entity.get_host())
		
	if sth_entity.has('Hill') and other_entity.could_have('Royal'):
		other_entity.get_node('Royal').enable()
		
func _on_sth_exited(sth, other):
	var sth_entity = ECM.E(sth)
	var other_entity = ECM.E(other)
	
	if not sth_entity or not other_entity:
		return
		
	if sth_entity.has('Flow') and other_entity.has('Flowing'):
		other_entity.get_node('Flowing').disable()
		
	if sth_entity.has('Hill') and other_entity.has('Royal'):
		other_entity.get_node('Royal').disable()
		
func _physics_process(delta):
	for fluid in ECM.entities_with('Fluid'):
		var did_it = false
		for body in fluid.get_host().get_overlapping_bodies():
			var body_e = ECM.E(body)
			
			if not(body_e.has('Thrusters')):
				continue
				
			var do_it = false
			if body_e.has('Conqueror') and not(fluid.has('Conquerable') and fluid.get('Conquerable').get_species().species == body_e.get('Conqueror').get_species().species):
				do_it = true
			if body_e.has('Owned') and not(fluid.has('Conquerable') and fluid.get('Conquerable').get_species().species == body_e.get('Owned').get_owned_by().species):
				do_it = true
			if do_it:
				body_e.get('Thrusters').add_hindrance()
				did_it = true
				
		if did_it and fluid.get_host() is Cell:
			fluid.get_host().flash()
			
	for e_w_thrusters in ECM.entities_with('Thrusters'):
		e_w_thrusters.get('Thrusters').apply_damp()
		e_w_thrusters.get('Thrusters').reset_hindrances()
		
