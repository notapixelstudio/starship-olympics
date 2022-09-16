extends Manager

# WARNING this implementation works only if a field never changes components while an object is inside it
# FIXME need to switch to a continuous check + timeout

signal repel_cargo
func _on_sth_entered(sth, other):
	var sth_entity = ECM.E(sth)
	var other_entity = ECM.E(other)
	
	if not sth_entity or not other_entity:
		return
		
	if sth_entity.has('Water') and other_entity.could_have('Thrusters'):
		other_entity.get_node('Thrusters').disable()
		
	if sth_entity.has('Flow') and other_entity.could_have('Flowing'):
		other_entity.get_node('Flowing').set_flow(sth_entity.get_node('Flow'))
		other_entity.get_node('Flowing').enable()
		
	if sth_entity.has('CrownDropper') and other_entity.has('Cargo') and other_entity.get('Cargo').what is Crown:
		emit_signal('repel_cargo', other_entity.get_host())

	if sth_entity.has('Hill') and other_entity.could_have('Royal'):
		other_entity.get_node('Royal').enable()
		
	if other is Ship and sth_entity.has('PhaseThroughDeadly') and not other_entity.has('Dashing'):
		if sth_entity.could_have('Owned'):
			var killer = sth_entity.get('Owned').get_owned_by()
			if killer != other or not sth_entity.has("NoSelfDeadly"):
				other.die(killer)
		else:
			other.die(other)
	
func _on_sth_exited(sth, other):
	var sth_entity = ECM.E(sth)
	var other_entity = ECM.E(other)
	
	if not sth_entity or not other_entity:
		return
		
	if sth_entity.has('Water') and other_entity.could_have('Thrusters'):
		other_entity.get_node('Thrusters').enable()
		
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
			# ships
			if body_e.has('Conqueror') and not(fluid.has('Conquerable') and fluid.get('Conquerable').get_species() == body_e.get('Conqueror').get_species()):
				do_it = true
			# bombs
			if body_e.has('Owned') and not(fluid.has('Conquerable') and fluid.get('Conquerable').get_species() == body_e.get('Owned').get_owned_by()):
				do_it = true
			if do_it:
				body_e.get('Thrusters').add_hindrance()
				did_it = true
				
		if did_it and fluid.get_host() is Cell:
			fluid.get_host().flash()
			
	#for e_w_thrusters in ECM.entities_with('Thrusters'):
	#	e_w_thrusters.get('Thrusters').apply_damp()
	#	e_w_thrusters.get('Thrusters').reset_hindrances()


func activate_slomo(arena):
	arena.connect("unslomo",Callable(self,"deactivate_slomo").bind(arena),CONNECT_ONE_SHOT)
	$SlomoEffect.play()
	await $SlomoEffect.finished
	arena.connect("slomo",Callable(self,"activate_slomo").bind(arena),CONNECT_ONE_SHOT)
	
func deactivate_slomo(arena):
	$UnSlomoEffect.play()
	await $SlomoEffect.finished
	
