extends ModeManager

signal score
signal show_msg

func _on_sth_conquered(conquered_by, what, points=1):
	if enabled:
		emit_signal('score', conquered_by.get_id(), points*score_multiplier)
		emit_signal('show_msg', conquered_by.species, points*score_multiplier, what.position)
		
func _on_sth_lost(lost_by, what, points=1):
	if enabled:
		emit_signal('score', lost_by.get_id(), -points*score_multiplier)
		
