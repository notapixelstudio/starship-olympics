tool
extends Node2D
export var radius = 100 setget set_radius


func set_radius(new_radius):
	radius = new_radius
	if Engine.editor_hint:
		$Area2D/CollisionShape2D.shape.radius = radius
	
func _ready():
	pass