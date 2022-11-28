extends RigidBody2D
class_name Pew

export var PfftScene : PackedScene

var ship : Ship
var ownership_transfer := true

var previous_velocity := Vector2.LEFT

func _ready():
	AudioManager.play($RandomAudioStreamPlayer)

func _physics_process(delta):
	previous_velocity = linear_velocity

func _process(delta):
	$Wrapper.rotation = linear_velocity.angle()

func _on_ForwardBullet_body_entered(body):
	if not (body is Mirror):
		destroy()
		
	if body.has_method('damage'):
		body.damage(self, ship)
		
	if body is Ball and has_ownership_transfer() and ship != null and is_instance_valid(ship):
		body.set_player(ship.get_player())
		body.activate()

func set_ship(v : Ship):
	ship = v
	$"%Sprite".modulate = ship.get_color()
	$AutoTrail.starting_color = ship.get_color()
	
func dissolve() -> void:
	var pfft = PfftScene.instance()
	if ship != null and is_instance_valid(ship):
		pfft.set_color(ship.get_color())
	get_parent().add_child(pfft)
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
	
