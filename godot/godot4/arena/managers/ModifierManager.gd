extends Node

@export_enum(&'winter') var active_modifiers : Array[String]
@export var winter_style : Style
@export var ice_scene : PackedScene

func apply_all() -> void:
	for modifier in active_modifiers:
		if modifier == &'winter':
			apply_winter()

func apply_winter() -> void:
	%Styleable.style = winter_style
	Styleable.reapply_all_styles()
	
	var shapes
	if %OutsideWallShape:
		shapes = [%OutsideWallShape]
	else:
		shapes = get_tree().get_nodes_in_group('platform_shape')
	
	for shape in shapes:
		var ice = ice_scene.instantiate()
		shape.get_parent().add_child(ice)
		shape.add_host(ice)
		
	for grid in get_tree().get_nodes_in_group('Grid'):
		grid.queue_free()
