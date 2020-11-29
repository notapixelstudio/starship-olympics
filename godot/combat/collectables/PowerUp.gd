tool

extends RigidBody2D

class_name PowerUp

export var type = 'shield'

export var appear = true

func _ready():
	$Glow/AnimationPlayer.play('Blink')
	$Glow/AnimationPlayer.seek(1.2, true)
	
	if appear:
		$AnimationPlayer.play('AppearFuhfuhfuh')
		
