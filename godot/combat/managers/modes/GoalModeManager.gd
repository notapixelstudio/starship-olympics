extends ModeManager

signal score
signal dropped
func _on_goal_entered(ship, goal):
	if not(ship is Ship):
		return
		
	if ECM.E(ship).has('Ringed'):
		if ship.species.species_name == goal.species.species_name:
			emit_signal('score', ship.get_id(), 1)
		else:
			emit_signal('score', ship.get_id(), -1)
			
		#ECM.E(ship).get('Ringed').disable()
		#var what = ECM.E(ship).get('Cargo').unload()
		#emit_signal('dropped', {'position': Vector2(), 'linear_velocity': Vector2()}, what)
		#emit_signal('show_score', ship.species_template, 1, ship.global_position)
	#else:
		#emit_signal('score', ship.species, -1)
		#emit_signal('show_score', ship.species_template, -1, ship.global_position)
		
func _on_sth_collected(collector, collectee):
	if collectee is Ring and ECM.E(collector).could_have('Ringed'):
		ECM.E(collector).get('Ringed').enable()
		
func _on_sth_stolen(thief, mugged):
	if ECM.E(mugged).has('Ringed') and ECM.E(thief).could_have('Ringed'):
		var stuff = ECM.E(mugged).get('Cargo').unload()
		assert(stuff is Ring)
		ECM.E(mugged).get('Ringed').disable()
		yield(get_tree(), "idle_frame")
		ECM.E(thief).get('Cargo').load(stuff)
		ECM.E(thief).get("Ringed").enable()
		
func _on_sth_dropped(dropper, droppee):
	if droppee is Ring and ECM.E(dropper).has('Ringed'):
		ECM.E(dropper).get('Ringed').disable()
		