class_name Missile extends RigidBody2D

@export var PfftScene : PackedScene

@onready var _ctx := ArenaScope.get_scope(self)

var _team : String
var _color : Color

func _ready():
	_update_rotation()
	#SoundEffects.play($RandomAudioStreamPlayer)

func _process(delta):
	_update_rotation()
	
func _update_rotation() -> void:
	%Graphics.rotation = linear_velocity.angle()

func _on_body_entered(body):
	_ctx.collision.emit(self, body)
	
func set_team(v:String) -> void:
	_team = v # remember team to avoid friendly fire (or checking up a dead ship)
	
func set_color(v:Color) -> void:
	_color = v
	
	%Sprite2D.modulate = _color
	%AutoTrail.modulate = _color
	
func dissolve() -> void:
	var pfft = PfftScene.instantiate()
	pfft.set_color(_color)
	_ctx.spawn_request.emit(pfft)
	pfft.global_position = global_position

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func destroy() -> void:
	dissolve()
	queue_free()


func _on_life_timer_timeout():
	destroy()
