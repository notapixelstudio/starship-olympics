extends ModeManager

signal show_msg

onready var sound_action = $GrabAction

func _on_sth_collected(collector, collectee):
	if collectee is Crown and ECM.E(collector).could_have('Royal'):
		ECM.E(collector).get('Royal').enable()
		sound_action.play()
		
func _on_sth_dropped(dropper, droppee):
	if droppee is Crown and ECM.E(dropper).has('Royal'):
		ECM.E(dropper).get('Royal').disable()
		
func _on_sth_stolen(thief, mugged):
	if ECM.E(mugged).has('Royal') and ECM.E(thief).could_have('Royal'):
		var stuff = ECM.E(mugged).get('Cargo').unload()
		assert(stuff is Crown)
		ECM.E(mugged).get('Royal').disable()
		yield(get_tree(), "idle_frame")
		ECM.E(thief).get('Cargo').load(stuff)
		ECM.E(thief).get("Royal").enable()
		sound_action.play()
