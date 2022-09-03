extends Manager

func _on_ship_detected(sth : CollisionObject2D, ship : Ship):
	if not enabled:
		return
	var entity = ECM.E(sth)
	
	if not entity:
		return
		
	if entity.has('Owned'):
		var owner = entity.get('Owned').get_owned_by()
		if not is_instance_valid(owner) or owner.get_team() == ship.get_team():
			return
		
	if entity.has('Owned') and len(ECM.entities_with('Royal')) > 0:
		var royal_species = {}
		for queen in ECM.entities_with('Royal'):
			royal_species[queen.get_host().species] = true
			
		if not entity.get('Owned').get_owned_by().species in royal_species and not ECM.E(ship).has('Royal'):
			return # FIXME? owner could be an invalid instance
		
	if entity.has('Pursuer') and entity.get('Pursuer').has_detection_insensitive_timed_out():
		var old_target = entity.get('Pursuer').get_last_valid_target()
		if ship != old_target:
			# pursue time is renewed only if a new target is found
			entity.get('Pursuer').set_keep_target_timeout()
			
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
		
		if global.arena.is_ship_valid(target):
			targeter_e.get('Pursuer').thrust = min(50.0, targeter_e.get('Pursuer').thrust+0.7)
			
			targeter.apply_impulse(Vector2(0,0), (target.position - targeter.position).normalized()*targeter_e.get('Pursuer').thrust)
			
