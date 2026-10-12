class_name AimAtTarget extends ActorBehavior
## Aims a child node at a target, preferring cargo-carrying ships.

@export var weapon_path: NodePath = ^"Weapons"

func _physics_process(_delta: float) -> void:
	var weapon := actor.get_node_or_null(weapon_path) as Node2D
	var target := _find_target()
	if weapon != null and target != null:
		weapon.global_rotation = actor.global_position.angle_to_point(target.global_position)

func _find_target() -> Node2D:
	for candidate in get_tree().get_nodes_in_group("Ship"):
		if candidate is Node2D and candidate.has_method("has_cargo") and candidate.has_cargo():
			return candidate
	for candidate in get_tree().get_nodes_in_group("Cargo"):
		if candidate is Node2D:
			return candidate
	return null
