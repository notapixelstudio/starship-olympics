extends Ball
class_name TennisBall

@export var starting_count := 5
var _count := starting_count

func _ready():
	super()
	_update_counter()
	
func decrease() -> void:
	_count -= 1
	if _count <= 0:
		_count = starting_count
		Events.score.emit(starting_count, get_owner_ship(), global_position)
		
	_update_counter()
	
func reset() -> void:
	_count = starting_count
	_update_counter()
	
func _update_counter() -> void:
	%Counter.text = str(_count)
