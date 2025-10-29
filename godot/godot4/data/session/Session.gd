extends Resource

class_name Session
var scores: Array[Scores] = []

var uuid : String
var players : Array
var timestamp_local : String
var timestamp : String


func get_last_score()->Scores:
	return scores[-1]
	
func add_match_results(match_results:Dictionary) -> void:
	var s = Scores.new(match_results)
	scores.append(s)

# virtual
func is_over() -> bool:
	return false

# virtual
func is_winner(team:String) -> bool:
	return false
