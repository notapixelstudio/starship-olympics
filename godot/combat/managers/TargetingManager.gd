extends Manager

func _on_ship_detected(other : CollisionObject2D, ship : Ship):
	var entity = ECM.E(other)
	
	if not entity:
		return
		
	if entity.could_have('Targeting') and entity.get('Targeting').has_detection_insensitive_timed_out():
		var old_target = entity.get('Targeting').get_target()
		if ship != old_target:
			entity.get('Targeting').enable()
			entity.get('Targeting').set_target(ship)
			entity.get('Targeting').reset_detection_insensitive_timeout()
			if other is Bull:
				$BullTargetLocked.play()
			else:
				$TargetLocked.play()
				
func _physics_process(delta):
	for targeter_e in ECM.entities_with('Targeting'):
		targeter_e.get('Targeting').update_timeouts(delta)
		
		var targeter = targeter_e.get_host()
		var target = targeter_e.get('Targeting').get_target()
		
		if targeter_e.has('Thrusters'):
			var thrust = 50 # FIXME read from thrusters
			targeter.apply_impulse(Vector2(0,0), (target.position - targeter.position).normalized()*thrust) # need a meaningful way to do this
		