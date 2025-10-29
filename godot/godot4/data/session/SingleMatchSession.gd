extends Session
class_name SingleMatchSession
## A Session comprising of a one-off match. Can have multiple winners if the match was tied.

@export var _winning_teams : Array[String] = []

func add_match_results(match_results:Dictionary) -> void:
	# simply store the winners of the match as winners of the entire session
	_winning_teams = match_results['winners']
	super.add_match_results(match_results)
	
func is_winner(team:String) -> bool:
	return team in _winning_teams

func is_over() -> bool:
	# this type of session is over if there's at least a winner
	return len(_winning_teams) > 0
