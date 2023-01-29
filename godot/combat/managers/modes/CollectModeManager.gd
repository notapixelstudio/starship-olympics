extends ModeManager

const MULTIPLIER = 2

signal show_msg

func _on_sth_collected(collector, collectee):
	if not enabled:
		return
		
	if collectee is Diamond or collectee is Star:
		var score_points = score_multiplier*collectee.points
		.score(collector.get_id(), score_points)
		emit_signal('show_msg', collector.species, score_points, collectee.global_position)
		AudioManager.play($"%AudioCollectAction")
		
func _on_coins_dropped(dropper, amount):
	emit_signal('score', dropper.get_id(), -score_multiplier * amount)



