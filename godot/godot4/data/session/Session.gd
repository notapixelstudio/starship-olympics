extends Resource

class_name Session

# virtual
func add_match_results(match_results:Dictionary) -> void:
	pass

# virtual
func is_over() -> bool:
	return false

# virtual
func is_winner(team:String) -> bool:
	return false
