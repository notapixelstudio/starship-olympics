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

func capture_ship(ship:Ship) -> void:
	var bubble = ship_bubble_scene.instantiate()
	bubble.set_player(ship.get_player())
	bubble.global_position = ship.global_position
	ship.queue_free()
	get_parent().add_child.call_deferred(bubble)
	bubble.set_content_rotation(ship.global_rotation)
	Events.ship_captured.emit.call_deferred(ship, bubble)
	
func capture_treasure(treasure:Treasure) -> void:
	var bubble = bubble_scene.instantiate()
	bubble.set_content(treasure)
	bubble.add_to_group('Treasure')
	bubble.global_position = treasure.global_position
	get_parent().remove_child.call_deferred(treasure)
	get_parent().add_child.call_deferred(bubble)
	bubble.set_content_rotation(treasure.global_rotation)
	
func destroy() -> void:
	var effect = bubble_popped_scene.instantiate()
	effect.global_position = global_position
	effect.scale = 0.5*Vector2(1,1)
	get_parent().add_child(effect)
	queue_free()


func _on_touch_area_2d_body_entered(sth: Node2D) -> void:
	Events.collision.emit(self, sth, 'touch')
	
