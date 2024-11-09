extends Node2D

@export var grid_color : Color = Color.GRAY
@export var cell_size := Vector2.ONE * 100
@export var frames_wait := 3
@export var scale_mask_texture := Vector2.ONE
@export var factor_viewport_multiplier := 1.5
@export var enabled : bool = true
@export var init_shape : VParametricShape # FIXME it would be nice to also support VCustomShape, but it's a different base node
@export var mask_shape : VParametricShape

@onready var mask = $Mask
@onready var grid = $Mask/Grid

func init_grid(arena_size: Vector2, offset := Vector2.ZERO):
	grid.init_grid(arena_size)
	grid.position += offset
	
func _ready():
	mask.multiplier = factor_viewport_multiplier
	mask.frames_wait = frames_wait
	mask.shape_node = mask_shape
	mask.scale_texture = scale_mask_texture
	grid.grid_color = grid_color
	grid.cell_size = cell_size
	
	init_grid(init_shape.get_extents())

	mask.set_process(enabled)
	grid.set_process(enabled)
	
