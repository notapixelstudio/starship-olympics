extends Node2D

@export var grid_color : Color = Color(0.0795,0.199633,0.53,1)
@export var cell_size := Vector2.ONE * 150
#@export var frames_wait := 3
#@export var enabled : bool = true
@export var init_parametric_shape : VParametricShape
@export var init_custom_shape : VCustomShape

@onready var mask = %Mask
@onready var grid = %GridLines

func _ready():
	#mask.frames_wait = frames_wait
	grid.grid_color = grid_color
	grid.cell_size = cell_size
	if init_parametric_shape:
		grid.init_grid(init_parametric_shape.get_extents())
	elif init_custom_shape:
		grid.init_grid(init_custom_shape.get_extents())
		
	#mask.set_process(enabled)
	#grid.set_process(enabled)
	
func set_points(points: PackedVector2Array) -> void:
	mask.set_points(points)
