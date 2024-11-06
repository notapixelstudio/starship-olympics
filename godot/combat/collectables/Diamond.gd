@tool

extends RigidBody2D

class_name Diamondz

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
	else:
		self.set_tangible(true)
		
func get_strategy(ship, distance, game_mode):
	return {'seek': points}
	
func set_tangible(tangible : bool):
	call_deferred('set_collision_mask_value', 1, tangible) # ship near area
	
func set_appear(v : bool) -> void:
	appear = v
	
func get_texture() -> Texture2D:
	return $Sprite2D.texture

func get_sprite_position() -> Vector2:
	return $Sprite2D.position
	
func touched_by(toucher : Ship):
	Events.sth_collected.emit(toucher, self)
	var particles = $Particles
	remove_child(particles)
	get_parent().add_child(particles)
	particles.global_position = global_position
	particles.go()
	queue_free()
	
func drop() -> void:
	$DropAnimationPlayer.play("drop")
