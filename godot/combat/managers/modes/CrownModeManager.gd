extends Manager

# move crown -> royal code here

signal score
func _process(delta):
	for royal in ECM.entities_with('Royal'):
		assert royal.get_host() is Ship
		
		emit_signal('score', royal.get_host().species, delta)
		