extends ModeManager

const MULTIPLIER = 2

signal show_msg

onready var sound_action = $CollectAction

func _on_sth_collected(collector, collectee):
	if not enabled:
		return
		
	if collectee is Diamond or collectee is Star:
		var score_points = score_multiplier*collectee.points
		global.the_match.add_score_to_team(collector.get_team(), score_points)
		global.arena.show_msg(collector.get_player().species, score_points, collectee.global_position)
		
func _on_coins_dropped(dropper, amount):
	global.the_match.add_score_to_team(dropper.get_team(), -score_multiplier * amount)
