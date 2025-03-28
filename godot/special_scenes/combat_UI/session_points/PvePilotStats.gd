extends PilotStats

var _medal := ''


func _compute_score():
	return session.get_medal()

func _update_icon(icon, i, score) -> void:
	icon.set_medal(score)
