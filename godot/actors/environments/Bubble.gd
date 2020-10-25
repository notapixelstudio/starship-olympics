extends RigidBody2D

onready var radius = $CollisionShape2D.shape.radius

func _process(delta):
	$Sprite.rotation = -rotation
	
