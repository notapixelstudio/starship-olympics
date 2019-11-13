extends Manager

func _on_ship_detected(sth : CollisionObject2D, ship : Ship):
	var entity = ECM.E(sth)
	
	if not entity:
		return
		
	if entity.has('Owned') and entity.get('Owned').get_owned_by().species == ship.species:
		return
		
	if entity.has('Owned') and len(ECM.entities_with('Royal')) > 0:
		var royal_species = {}
		for queen in ECM.entities_with('Royal'):
			royal_species[queen.get_host().species] = true
			
		if not entity.get('Owned').get_owned_by().species in royal_species and not ECM.E(ship).has('Royal'):
			return
		
	if entity.has('Pursuer'):
		entity.get('Pursuer').set_keep_target_timeout()
		
		if entity.get('Pursuer').has_detection_insensitive_timed_out():
			var old_target = entity.get('Pursuer').get_target()
			if ship != old_target:
				entity.get('Pursuer').set_target(ship)
				entity.get('Pursuer').set_detection_insensitive_timeout()
				if sth is Bull:
					$BullTargetLocked.play()
				else:
					$TargetLocked.play()
					
func _physics_process(delta):
	for targeter_e in ECM.entities_with('Pursuer'):
		targeter_e.get('Pursuer').update_timeouts(delta)
		
		if targeter_e.get('Pursuer').has_keep_target_timed_out():
			targeter_e.get('Pursuer').set_target(null)
			continue
		
		var targeter = targeter_e.get_host()
		var target = targeter_e.get('Pursuer').get_target()
		
		if target != null and targeter_e.has('Thrusters'):
			var thrust = 50
			targeter.apply_impulse(Vector2(0,0), (target.position - targeter.position).normalized()*thrust)
			