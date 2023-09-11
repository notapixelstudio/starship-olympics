@tool
extends Node2D

@export var rows := 50
@export var columns := 50
@export var dx := 50
@export var dy := 50
@export var color := Color.WHITE
@export var border_color := Color.WHITE
@export var major_line_every := 2

func _ready():
	position = Vector2(-columns*dx/2.0, -rows*dy/2.0)

func _draw():
	for j in range(1,columns):
		draw_line(Vector2(j*dx, 0.0), Vector2(j*dx, rows*dy), color, 0.8 if j % major_line_every else 1.0, true)
		
	for i in range(1,rows):
		draw_line(Vector2(0.0, i*dy), Vector2(columns*dx, i*dy), color, 0.8 if i % major_line_every else 1.0, true)
	
	draw_rect(Rect2(0.0, 0.0, columns*dx, rows*dy), border_color, false, 4.0)
