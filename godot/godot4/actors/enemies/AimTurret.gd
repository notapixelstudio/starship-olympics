extends Turret
class_name AimTurret

func _physics_process(delta: float) -> void:
	# shoot ships if they have a cargo
	var targets = get_tree().get_nodes_in_group('Ship')
	
	for target in targets:
		if target.has_cargo():
			# aim to first available target with cargo
			%Weapons.global_rotation = global_position.angle_to_point(target.global_position)
			return
	
	# shoot cargos if nothing was found
	targets = get_tree().get_nodes_in_group('Cargo')
	if len(targets) <= 0:
		return
		
	%Weapons.global_rotation = global_position.angle_to_point(targets[0].global_position)
