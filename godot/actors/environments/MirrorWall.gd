tool
extends Wall

class_name MirrorWall

const texture = preload('res://assets/patterns/rhombus.png')

func _ready():
	$InnerPolygon2D.texture = texture
	$InnerPolygon2D.texture_scale = Vector2(1,1)

func damage(hazard, damager):
	$AnimationPlayer.advance(10) # should be enough to end the current animation and make the sector flash again
	$AnimationPlayer.play("Hit")
