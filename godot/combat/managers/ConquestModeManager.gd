extends ModeManager

signal score

func _on_sth_conquered(conquered_by, what):
	emit_signal('score', conquered_by.species_name, 8)

#TODO better name
func _on_sth_deconquered(deconquered_by, what):
	emit_signal('score', deconquered_by.species_name, -8)