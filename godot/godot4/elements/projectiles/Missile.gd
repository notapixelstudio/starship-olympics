class_name Missile extends RigidBody2D

@export var PfftScene : PackedScene
@export var explosion_scene : PackedScene

@onready var _ctx := ArenaScope.get_scope(self)

var _player : Player

func _ready():
	_update_rotation()
	#SoundEffects.play($RandomAudioStreamPlayer)

func _process(delta):
	_update_rotation()
	
func _update_rotation() -> void:
	%Graphics.rotation = linear_velocity.angle()

func _on_body_entered(body):
	_ctx.collision.emit(self, body)
	
func set_player(v:Player) -> void:
	_player = v
	%Sprite2D.modulate = _player.get_color()
	#%AutoTrail.modulate = _player.get_color()
	
func get_player() -> Player:
	return _player
	
	
func dissolve() -> void:
	var pfft = PfftScene.instantiate()
	pfft.set_color(_player.get_color())
	_ctx.spawn_request.emit(pfft)
	pfft.global_position = global_position

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func destroy() -> void:
	dissolve()
	queue_free()

func _on_life_timer_timeout():
	destroy()

func touched_by(ship:Ship) -> void:
	if ship.get_team() != _player.get_team():
		detonate()
		
func detonate():
	var explosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	explosion.set_player(_player)
	_ctx.spawn_request.emit(explosion)
	queue_free()


func _on_hurt_area_body_entered(body: Node2D) -> void:
	if body == self:
		return
		
	_ctx.collision.emit(self, body, 'hurt')
	
