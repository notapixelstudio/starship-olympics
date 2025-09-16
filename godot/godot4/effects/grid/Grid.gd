extends Node2D

@export var cell_size := Vector2.ONE * 150
@export var dy := 32.0 : set = set_dy
#@export var frames_wait := 3
#@export var enabled : bool = true
@export var init_parametric_shape : VParametricShape
@export var init_custom_shape : VCustomShape

@onready var mask = %Mask
@onready var grid = %GridLines

func set_dy(v:float) -> void:
	dy = v
	%Mask.position.y = dy
	
func set_style(style:Style) -> void:
	%GridLines.color = style.grid_color

func _ready():
	set_style(%Styleable.get_style_from_ancestor_or_self())
	
	#mask.frames_wait = frames_wait
	grid.cell_size = cell_size
	if init_parametric_shape:
		grid.size = init_parametric_shape.get_extents()
	elif init_custom_shape:
		grid.size = init_custom_shape.get_extents()
	grid.init_grid()
	
	#mask.set_process(enabled)
	#grid.set_process(enabled)
	
	# MESH SUPPORT
	#%GridLines.mesh = %MeshInstance2D.mesh # FIXME please
	
func set_points(points: PackedVector2Array) -> void:
	mask.set_points(points)
