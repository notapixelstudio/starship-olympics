extends Node

var _int_max_score : int

func set_max_score(value: float) -> void:
	_int_max_score = int(value)

func _ready() -> void:
	Events.score_updated.connect(_on_score_updated)
	Events.clock_expired.connect(_on_clock_expired)
	
func _on_score_updated(score: float, team: String) -> void:
	if int(score) >= _int_max_score:
		Events.log.emit('Team [b]%s[/b] wins the match with perfect score %d (%d points actually).' % [team, _int_max_score, score])
		Events.match_over.emit({'winner': team})

func _on_clock_expired() -> void:
	Events.log.emit('Match ended because time has ran out.')
	Events.match_over.emit({'winner': 'pippo'})
