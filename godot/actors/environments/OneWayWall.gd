tool
extends StaticBody2D

export var width = 600 setget set_width

func set_width(v):
	width = v
	$CollisionShape2D.shape.extents.x = width/2
	$Line2D.width = width
	
