extends Node

@export_enum(&'winter') var active_modifiers : Array[String]
@export var ice_scene : PackedScene

func apply_all() -> void:
	for modifier in active_modifiers:
		if modifier == &'winter':
			apply_winter()

func apply_winter(shapes=null) -> void:
	if shapes == null:
		# default
		shapes = [%OutsideWallShape]
	
	for shape in shapes:
		var ice = ice_scene.instantiate()
		%Battlefield.add_child(ice)
		shape.add_host(ice)
		
	%Grid.queue_free()
