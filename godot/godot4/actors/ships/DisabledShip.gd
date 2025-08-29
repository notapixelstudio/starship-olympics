extends RigidBody2D
class_name DisabledShip

var player : Player

func get_player() -> Player:
	return player
	
func set_player(v: Player) -> void:
	player = v
	%Sprite2D.texture = player.get_ship_image()
	%UnderSprite.self_modulate = player.get_color()
	
#func _enter_tree():
	##linear_velocity = ship.linear_velocity
	#position = ship.position
	#rotation = ship.rotation
	#SoundEffects.play($RandomAudioStreamPlayer2D)
	
func damage(hazard, damager) -> void:
	$HitAnimationPlayer.play("hit")
	
func beep():
	SoundEffects.play($Beep)
	
