tool
extends Node2D
export (int) var radius setget set_radius


func set_radius(new_radius):
	radius = new_radius
	if has_node('Circle'):
		refresh()
	
func _ready():
	refresh()
	
func refresh():
	$Area2D/CollisionShape2D.shape.radius = radius
	$Circle.radius = radius