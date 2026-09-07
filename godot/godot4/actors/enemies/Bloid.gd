extends Shapeoid
class_name Bloid

func _ready() -> void:
	%Sprite2D.rotation = randf()*2*PI

func _process(delta: float) -> void:
	%Sprite2D.rotation += delta

func _physics_process(delta: float) -> void:
	# follow a ship at random
	var targets = get_tree().get_nodes_in_group('Ship')
	if len(targets) <= 0:
		return
		
	_direction = global_position.angle_to_point(targets[0].global_position)
	_move()
