extends Node2D

export var grid_color : Color = Color.gray
export var cell_size := Vector2.ONE * 100
export var frames_wait := 3
export var scale_mask_texture := Vector2.ONE
export var factor_viewport_multiplier := 1.1
export var enabled : bool = true

onready var mask = $MaskViewPort/Mask
onready var light = $Light2D
onready var viewport = $MaskViewPort
onready var grid = $Grid

func init_grid(arena_size: Vector2):
	grid.init_grid(arena_size)
	viewport.size = arena_size * float(1.0/scale_mask_texture.x) * factor_viewport_multiplier
	
func _ready():
	mask.multiplier = factor_viewport_multiplier
	mask.frames_wait = frames_wait
	light.scale = scale_mask_texture
	mask.scale_texture = scale_mask_texture
	grid.grid_color = grid_color
	grid.cell_size = cell_size
	

	mask.set_process(enabled)
	light.enabled = enabled
	grid.set_process(enabled)
	
