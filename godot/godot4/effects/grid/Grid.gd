extends Node2D

@export var cell_size := Vector2.ONE * 150
@export var dy := 32.0 : set = set_dy
@export var outline := false : set = set_outline
#@export var frames_wait := 3
#@export var enabled : bool = true
@export var init_parametric_shape : VParametricShape
@export var init_custom_shape : VCustomShape

@onready var mask = %Mask
@onready var grid = %GridLines

func set_dy(v:float) -> void:
	dy = v
	%Mask.position.y = dy
	
func set_outline(v:float) -> void:
	outline = v
	%Outline.visible = outline
	
func set_style(style:Style) -> void:
	%GridLines.grid_color = style.grid_color
	%Outline.default_color = style.grid_color

func _ready():
	set_style(%Styleable.get_style_from_ancestor_or_self())
	
	#mask.frames_wait = frames_wait
	grid.cell_size = cell_size
	if init_parametric_shape:
		grid.init_grid(init_parametric_shape.get_extents())
	elif init_custom_shape:
		grid.init_grid(init_custom_shape.get_extents())
		
	#mask.set_process(enabled)
	#grid.set_process(enabled)
	
	%GridLines.mesh = %MeshInstance2D.mesh # FIXME please
	
func set_points(points: PackedVector2Array) -> void:
	mask.set_points(points)
	%Outline.set_points(points)
