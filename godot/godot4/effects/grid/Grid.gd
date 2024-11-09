extends Node2D

@export var grid_color : Color = Color(0.0795,0.199633,0.53,1)
@export var cell_size := Vector2.ONE * 150
#@export var frames_wait := 3
#@export var enabled : bool = true
@export var init_shape : VParametricShape # FIXME it would be nice to also support VCustomShape, but it's a different base node

@onready var mask = %Mask
@onready var grid = %GridLines

func _ready():
	#mask.frames_wait = frames_wait
	grid.grid_color = grid_color
	grid.cell_size = cell_size
	grid.init_grid(init_shape.get_extents())
	
	#mask.set_process(enabled)
	#grid.set_process(enabled)
	
func set_points(points: PackedVector2Array) -> void:
	mask.set_points(points)
