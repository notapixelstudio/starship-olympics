extends RigidBody2D
class_name BubbleBullet

@export var bubble_scene : PackedScene
@export var ship_bubble_scene : PackedScene
@export var bubble_popped_scene : PackedScene
@export var lifetime := 10.0 # seconds

var _lifetime_left : float

func set_lifetime(v: float):
	lifetime = v

func _ready() -> void:
	_lifetime_left = lifetime
	
func _physics_process(delta: float) -> void:
	_lifetime_left -= delta
	%LifetimeSprite2D.scale = _lifetime_left / lifetime * Vector2(1,1)
	if _lifetime_left <= 0:
		destroy()

func hurt(sth) -> void:
	if sth is Ship:
		if not sth.is_dashing():
			var bubble = ship_bubble_scene.instantiate()
			bubble.set_player(sth.get_player())
			bubble.global_position = sth.global_position
			sth.queue_free()
			get_parent().add_child.call_deferred(bubble)
			bubble.set_content_rotation(sth.global_rotation)
			Events.ship_captured.emit.call_deferred(sth, bubble)
		destroy()

func destroy() -> void:
	var effect = bubble_popped_scene.instantiate()
	effect.global_position = global_position
	effect.scale = 0.5*Vector2(1,1)
	get_parent().add_child(effect)
	queue_free()


func _on_touch_area_2d_body_entered(sth: Node2D) -> void:
	if sth is Treasure:
		var bubble = bubble_scene.instantiate()
		bubble.set_content(sth)
		bubble.add_to_group('Treasure')
		bubble.global_position = sth.global_position
		get_parent().remove_child.call_deferred(sth)
		get_parent().add_child.call_deferred(bubble)
		bubble.set_content_rotation(sth.global_rotation)
		destroy()
