extends RigidBody2D

class_name DeadShip

export var cpu_ship_texture : Texture

var ship setget set_ship
var info_player
var species
var camera

signal bump

var entity : Entity

func _ready():
	entity = ECM.E(self)
	
func set_ship(new_value):
	ship = new_value
	camera = ship.camera
	info_player = ship.info_player
	species = ship.species
	
	if info_player.is_cpu():
		$Sprite.texture = cpu_ship_texture
		$Sprite.modulate = species.color
		$UnderSprite.self_modulate = species.color
		$UnderSprite.texture = cpu_ship_texture
	else:
		$Sprite.texture = species.ship
		$Sprite.modulate = Color.white
		$UnderSprite.self_modulate = species.color
		$UnderSprite.texture = species.ship
		
func _enter_tree():
	#linear_velocity = ship.linear_velocity
	position = ship.position
	rotation = ship.rotation
	if not $Trail2D.is_inside_tree():
		yield($Trail2D, "tree_entered")
	$Trail2D.erase_trail()
	SoundEffects.play($RandomAudioStreamPlayer2D)
	
func _integrate_forces(state):
	# force the physics engine
	var xform = state.get_transform()
	
	# teleport
	if entity.could_have('Teleportable') and entity.get('Teleportable').is_teleporting():
		xform.origin = entity.get('Teleportable').get_destination()
		entity.get('Teleportable').teleport_done()
		
	state.set_transform(xform)
	
const CAMERA_RECT_SIZE := 800.0
func get_camera_rect() -> Rect2:
	return Rect2(global_position - Vector2(CAMERA_RECT_SIZE,CAMERA_RECT_SIZE)/2, Vector2(CAMERA_RECT_SIZE,CAMERA_RECT_SIZE))

func damage(hazard, damager) -> void:
	$HitAnimationPlayer.play("hit")
	
func beep():
	SoundEffects.play($Beep)
	
