extends ModeManager

signal score

func _on_sth_conquered(conquered_by, what):
	if enabled:
		emit_signal('score', conquered_by.species, score_multiplier)
		
func _on_sth_lost(lost_by, what):
	if enabled:
		emit_signal('score', lost_by.species, -score_multiplier)
		