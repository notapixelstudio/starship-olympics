extends Node

@export var teams : Array[String] : set = set_teams
@export var starting_score := 0.0

var _scores := {}

func set_teams(v: Array[String]) -> void:
	teams = v

func _ready():
	for team in teams:
		_scores[team] = starting_score
		
	Events.points_scored.connect(_on_points_scored)
	
func _on_points_scored(amount: int, team: String) -> void:
	if not _scores.has(team):
		Events.log.emit('Error! [b]%s[/b] team not found.' % team)
		return
	
	_scores[team] += amount
	
	Events.log.emit('Team [b]%s[/b] scored %d points, and is now at %d points.' % [team, amount, _scores[team]])
