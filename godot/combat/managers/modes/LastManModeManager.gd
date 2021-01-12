extends ModeManager

signal score
signal broadcast_score
signal show_msg

func _on_sth_killed(sth, killer : Ship, ship_for_good=false):
	if not enabled:
		return
	
	if sth is Ship:
		.broadcast_score(sth.get_id(), score_multiplier)
		
