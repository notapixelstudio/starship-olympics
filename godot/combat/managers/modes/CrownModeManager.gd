extends ModeManager

func _on_sth_collected(collector, collectee):
	if collectee is Crown and ECM.E(collector).could_have('Royal'):
		ECM.E(collector).get('Royal').enable()
		
func _on_sth_dropped(dropper, droppee):
	if droppee is Crown and ECM.E(dropper).has('Royal'):
		ECM.E(dropper).get('Royal').disable()
		
signal score
func _process(delta):
	if not enabled:
		return
		
	for royal in ECM.entities_with('Royal'):
		assert royal.get_host() is Ship
		
		emit_signal('score', royal.get_host().species, delta)
		