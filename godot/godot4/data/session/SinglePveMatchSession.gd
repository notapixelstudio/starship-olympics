extends Session
class_name SinglePveMatchSession
## A PVE Session comprising of a one-off match.

@export var medal := ''

func is_winner(team:String) -> bool:
	# any medal is considered a win
	return medal != ''

func add_match_results(match_results:Dictionary) -> void:
	# simply store which medal threshold has been reached
	medal = match_results['medal']
	super.add_match_results(match_results)
	
func get_medal() -> String:
	return medal

func is_over() -> bool:
	# PVE sessions are always over
	# you can start a new one to perfect your score
	return true
