extends Area2D

export var active = false setget set_active

func set_active(v):
	active = v
	$Sprite.visible = active
	$CollisionShape2D.disabled = not active
	
