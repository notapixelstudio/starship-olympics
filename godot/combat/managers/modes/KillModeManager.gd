extends ModeManager

signal broadcast_score
signal show_msg

func _on_sth_killed(sth, killer : Ship, ship_for_good=false):
	if not enabled:
		return
	
	if sth is Ship:
		# self or team kill: there is not a specific killer (e.g., environment) or the killer is in the same team as the killed ship
		if not killer or killer is Ship and killer.info_player.team == sth.info_player.team:
			# the killed ship gets a negative score
			.score(sth.get_id(), -score_multiplier)
			emit_signal('show_msg', sth.species, -score_multiplier, sth.position)
			
		# proper kill: there's a specific killer, and it is not in the same team as the killed ship
		if killer and killer is Ship and killer.info_player.team != sth.info_player.team:
			.score(killer.get_id(), score_multiplier)
			emit_signal('show_msg', killer.species, score_multiplier, sth.position)
			
	elif sth is Brick or sth is Bubble:
		var score = sth.points*score_multiplier
		.score(killer.get_id(), score)
		emit_signal('show_msg', killer.species, score, sth.position)
		
