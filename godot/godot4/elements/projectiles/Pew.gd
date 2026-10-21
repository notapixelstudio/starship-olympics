extends RigidBody2D
class_name Pew

@export var PfftScene : PackedScene

var ownership_transfer := true

var previous_velocity := Vector2.LEFT

@onready var _ctx := ArenaScope.get_scope(self)

var _player : Player

func set_player(v: Player) -> void:
	_player = v
	
	%Sprite2D.modulate = _player.get_color()
	$AutoTrail.starting_color = Color(_player.get_color(), 0.1)
	$AutoTrail.ending_color = Color(Color.WHITE, 0)
	
func get_player() -> Player:
	return _player

func _ready():
	_update_rotation()
	SoundEffects.play($RandomAudioStreamPlayer)

func _physics_process(delta):
	previous_velocity = linear_velocity

func _process(delta):
	_update_rotation()
	
func _update_rotation() -> void:
	$Wrapper.rotation = linear_velocity.angle()

func _on_body_entered(body):
	_ctx.collision.emit(self, body)
	
	
func dissolve() -> void:
	var pfft = PfftScene.instantiate()
	pfft.set_color(_player.get_color())
	_ctx.spawn_request.emit(pfft)
	pfft.global_position = global_position

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func destroy() -> void:
	dissolve()
	queue_free()
	
func get_previous_velocity() -> Vector2:
	return previous_velocity

func disable_ownership_transfer() -> void:
	ownership_transfer = false

func has_ownership_transfer() -> bool:
	return ownership_transfer
	
func get_team() -> String:
	return _player.get_team()

func get_damage_amount() -> int:
	return 1
