extends Node

@export var teams : Array[String] : set = _set_teams
@export var starting_score := 0.0

var _scores := {}

func _set_teams(v: Array[String]) -> void:
	teams = v
	for team in teams:
		add_team(team)
		
func add_team(name:String) -> void:
	_scores[name] = starting_score

func _ready():
	reset_scores()
	Events.points_scored.connect(_on_points_scored)
	
func reset_scores():
	for team in teams:
		add_team(team)
		
func _on_points_scored(amount: float, team: String) -> void:
	if not _scores.has(team):
		Events.log.emit('Error! [b]%s[/b] team not found.' % team)
		return
	
	_scores[team] += amount
	
	Events.score_updated.emit(_scores[team], team)
	Events.log.emit('Team [b]%s[/b] scored %d points, and is now at %d points.' % [team, amount, _scores[team]])
