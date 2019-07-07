extends ModeManager

signal score

func _on_sth_conquered(conquered_by, what):
	if enabled:
		emit_signal('score', conquered_by.species, score_multiplier)
		
