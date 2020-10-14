extends ModeManager

signal score
signal broadcast_score
signal show_score

func _on_sth_killed(sth, killer : Ship):
	if not enabled:
		return
	
	if sth is Ship:
		if not killer or killer is Ship and killer.info_player.team == sth.info_player.team:
			emit_signal("broadcast_score", sth.get_id(), score_multiplier)
			
		elif killer and killer.species != sth.species:
			emit_signal('score', killer.get_id(), score_multiplier)
			emit_signal('show_score', killer.species, score_multiplier, sth.position)
	elif sth is Brick:
		var score = sth.points*score_multiplier
		emit_signal('score', killer.get_id(), score)
		emit_signal('show_score', killer.species, score, sth.position)
		
