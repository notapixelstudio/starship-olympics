@tool

extends RigidBody2D

class_name Diamond

@export var appear = true

var points = 1

func set_points(value):
	points = value
	
func _ready():
	$Glow/AnimationPlayer.play('Blink')
	$Glow/AnimationPlayer.seek(1.2, true)
	
	if appear:
		self.set_tangible(false)
		$AnimationPlayer.play('AppearFuhfuhfuh')
		
func get_strategy(ship, distance, game_mode):
	return {'seek': points}
	
func set_tangible(tangible : bool):
	set_collision_mask_value(1, tangible) # ship near area
	
