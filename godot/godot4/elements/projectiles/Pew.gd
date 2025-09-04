extends RigidBody2D
class_name Pew

@export var PfftScene : PackedScene

var ship : Ship
var ownership_transfer := true

var previous_velocity := Vector2.LEFT
var team : String

func _ready():
	_update_rotation()
	SoundEffects.play($RandomAudioStreamPlayer)

func _physics_process(delta):
	previous_velocity = linear_velocity

func _process(delta):
	_update_rotation()
	
func _update_rotation() -> void:
	$Wrapper.rotation = linear_velocity.angle()

func _on_ForwardBullet_body_entered(body):
	Events.collision.emit(self, body)
	
func set_ship(v : Ship):
	ship = v
	$"%Sprite2D".modulate = ship.get_color()
	$AutoTrail.starting_color = Color(ship.get_color(), 0.2)
	$AutoTrail.ending_color = Color(ship.get_color(), 0)
	team = ship.get_team() # remember team to avoid friendly fire (or checking up a dead ship)
	
func dissolve() -> void:
	var pfft = PfftScene.instantiate()
	if ship != null and is_instance_valid(ship):
		pfft.set_color(ship.get_color())
	Events.spawn_request.emit(pfft)
	pfft.global_position = global_position

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func destroy() -> void:
	dissolve()
	queue_free()

func get_owner_ship() -> Ship:
	return ship
	
func get_player():
	return ship.get_player()
	
func get_previous_velocity() -> Vector2:
	return previous_velocity

func disable_ownership_transfer() -> void:
	ownership_transfer = false

func has_ownership_transfer() -> bool:
	return ownership_transfer
	
func get_team() -> String:
	return team

func get_damage_amount() -> int:
	return 1
