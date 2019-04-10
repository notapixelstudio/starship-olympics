extends ModeManager

signal score

func _on_sth_conquered(conquered_by, what):
	if enabled:
		emit_signal('score', conquered_by.species, 8)

#TODO better name
func _on_sth_deconquered(deconquered_by, what):
	if enabled:
		emit_signal('score', deconquered_by.species, -8)