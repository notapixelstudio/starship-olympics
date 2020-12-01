extends ModeManager

signal score

func _on_sth_conquered(conquered_by, what, points=1):
	if enabled:
		emit_signal('score', conquered_by.get_id(), points*score_multiplier)
		
func _on_sth_lost(lost_by, what, points=1):
	if enabled:
		emit_signal('score', lost_by.get_id(), -points*score_multiplier)
		
