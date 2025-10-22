extends Node
class_name ScoreManager

@export var teams : Array[String] : set = _set_teams
@export var starting_score := 0.0

var _scores := {}
var _standings := []
var _thresholds := []
var _next_threshold_index := 0

func _set_teams(v: Array[String]) -> void:
	teams = v
	for team in teams:
		add_team(team)
		
func add_team(name:String) -> void:
	_scores[name] = starting_score

func set_thresholds(values:Array) -> void:
	_thresholds = values
	
func _ready() -> void:
	reset_scores()
	Events.points_scored.connect(_on_points_scored)
	
func reset_scores() -> void:
	for team in teams:
		add_team(team)
	_compute_standings()
	
func _compute_standings() -> void:
	_standings = _scores.keys().map(func(k): return {'team': k, 'score': _scores[k]})
	_standings.sort_custom(func(a,b): return a['score'] > b['score'])
	
func _on_points_scored(amount: float, team: String) -> void:
	if not _scores.has(team):
		Events.log.emit('Error! [b]%s[/b] team not found.' % team)
		return
	
	_scores[team] += amount
	_compute_standings()
	
	Events.score_updated.emit(_scores[team], team, _standings)
	Events.log.emit('Team [b]%s[/b] scored %d points, and is now at %d points.' % [team, amount, _scores[team]])
	
	# signal if a team passed a score threshold
	if _next_threshold_index < len(_thresholds) and _scores[team] >= _thresholds[_next_threshold_index]:
		Events.score_threshold_passed.emit(team)
		_next_threshold_index += 1
