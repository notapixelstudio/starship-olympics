extends Shapeoid


func _ready() -> void:
	_direction = [PI/4,-PI/4,3*PI/4,-3*PI/4].pick_random()

func _physics_process(delta: float) -> void:
	_move()
