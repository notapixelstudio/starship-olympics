class_name Explosion extends Area2D

@onready var _ctx := ArenaScope.get_scope(self)

var _player : Player

func _ready():
	$Halo.scale.x = 0.4
	$Halo.rotation = randf()*2*PI
	
	$Spikes.rotation = randf()*2*PI
	
func set_player(v:Player) -> void:
	_player = v
	
func get_player() -> Player:
	return _player
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	_ctx.collision.emit(body, self)
