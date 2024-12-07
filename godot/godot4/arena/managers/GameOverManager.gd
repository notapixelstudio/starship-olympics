extends Node


var _int_max_score : int
var _latest_standings : Array = []

func set_max_score(value: float) -> void:
	_int_max_score = int(value)

func _ready() -> void:
	Events.score_updated.connect(_on_score_updated)
	Events.clock_expired.connect(_on_clock_expired)
	
func _on_score_updated(score: float, team: String, new_standings: Array) -> void:
	_latest_standings = new_standings
	
	# we need to check perfect after other potential callbacks have fired
	# other scores could be updated during this frame
	# this is needed for minigames that assign score simultaneously
	_check_if_perfect.call_deferred()

func _on_clock_expired() -> void:
	Events.log.emit('Match ended because time has ran out.')
	_end_the_match()

func _check_if_perfect() -> void:
	# if any of the teams has a perfect score, the match should end
	for standing in _latest_standings:
		if int(standing['score']) >= _int_max_score:
			Events.log.emit('Match ended with perfect score %d.' % _int_max_score)
			_end_the_match()
			return
			
func _end_the_match() -> void:
	var winners : Array[String] = []
	var best_score : float = _latest_standings[0]['score'] if len(_latest_standings) > 0 else 0.0
	for standing in _latest_standings:
		if abs(standing['score'] - best_score) < 0.1:
			winners.append(standing['team'])
		else:
			break # standings are sorted
	Events.match_over.emit({'winners': winners, 'standings': _latest_standings}) # no winners if score is zero
	
