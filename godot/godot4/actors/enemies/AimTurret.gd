extends Turret
class_name AimTurret

func _physics_process(delta: float) -> void:
	var targets = get_tree().get_nodes_in_group('Ship')
	if len(targets) <= 0:
		return
		
	# aim to first available target
	global_rotation = global_position.angle_to_point(targets[0].global_position)
