extends Node2D

export var radius = 100

func _ready():
	$Area2D/CollisionShape2D.shape.radius = radius
	$Circle.radius = radius