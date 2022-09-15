tool

extends RigidBody2D

class_name Diamond

export var appear = true

var points = 1

func set_points(value):
	points = value
	
func _ready():
	$Glow/AnimationPlayer.play('Blink')
	$Glow/AnimationPlayer.seek(1.2, true)
	
	if appear:
		self.set_tangible(false)
		$AnimationPlayer.play('AppearFuhfuhfuh')
	else:
		self.set_tangible(true)
		
func get_strategy(ship, distance, game_mode):
	return {'seek': points}
	
func set_tangible(tangible : bool):
	set_collision_mask_bit(1, tangible) # ship near area
	
func set_appear(v : bool) -> void:
	appear = v
	
func get_texture() -> Texture:
	return $Sprite.texture
