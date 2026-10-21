extends Node2D

@export var cell_size := Vector2.ONE * 150
@export var dy := 32.0 : set = set_dy
#@export var frames_wait := 3
#@export var enabled : bool = true
@export_enum('square', 'diagonal', 'triangular') var type = "square"

@export var init_parametric_shape : VParametricShape
@export var init_custom_shape : VCustomShape

@onready var mask = %Mask
@onready var grid = %GridLines

func set_dy(v:float) -> void:
	dy = v
	%Mask.position.y = dy
	
func set_style(style:Style) -> void:
	%GridLines.color = style.grid_color
	%GridLines.visible = style.grid_visible
	%GridLines.grid_thickness = style.grid_thickness
	%MeshInstance2D.texture = style.mesh_texture
	%MeshInstance2D.visible = style.mesh_visible
	%MeshInstance2D.modulate = style.mesh_color
	%GridLines.checkered = style.mesh_checkered
	%GridLines.enabled = %GridLines.visible or %MeshInstance2D.visible
	
	for child in get_children():
		if child is Node2D:
			child.self_modulate = style.grid_color
			
func _ready():
	%Styleable.apply_current_style()
	
	#mask.frames_wait = frames_wait
	grid.cell_size = cell_size
	if init_parametric_shape:
		await init_parametric_shape.updated
		grid.size = init_parametric_shape.get_extents()
	elif init_custom_shape:
		await init_custom_shape.updated
		grid.size = init_custom_shape.get_extents()
	grid.type = type
	grid.init_grid()
	
	#mask.set_process(enabled)
	#grid.set_process(enabled)
	
	# MESH SUPPORT
	%GridLines.mesh = %MeshInstance2D.mesh # FIXME please
	
func set_points(points: PackedVector2Array) -> void:
	# WARNING shapes that grow bigger than their starting extent are not supported 
	mask.set_points(points)
