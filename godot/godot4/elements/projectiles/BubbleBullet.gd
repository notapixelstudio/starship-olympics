extends RigidBody2D
class_name BubbleBullet

@export var bubble_scene : PackedScene
@export var ship_bubble_scene : PackedScene
@export var bubble_popped_scene : PackedScene
@export var lifetime := 10.0 # seconds

@onready var _ctx := ArenaScope.get_scope(self)

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
	bubble.set_ship(ship)
	bubble.global_position = ship.global_position
	ship.capture(self)
	ship.queue_free()
	_ctx.spawn_request.emit(bubble)
	bubble.set_content_rotation(ship.global_rotation)
	Events.ship_captured.emit.call_deferred(ship, bubble)
	
func capture_nonship_element(element:Node2D) -> void:
	var bubble = bubble_scene.instantiate()
	bubble.set_content(element)
	if element is Treasure:
		bubble.add_to_group('Treasure')
	elif element is Shapeoid:
		bubble.add_to_group('Shapeoid')
	bubble.global_position = element.global_position
	bubble.set_content_rotation(element.global_rotation)
	get_parent().remove_child.call_deferred(element) # FIXME ask the context
	_ctx.spawn_request.emit(bubble)
	
func destroy() -> void:
	var effect = bubble_popped_scene.instantiate()
	effect.global_position = global_position
	effect.scale = 0.5*Vector2(1,1)
	_ctx.spawn_request.emit(effect)
	queue_free()


func _on_touch_area_2d_body_entered(sth: Node2D) -> void:
	_ctx.collision.emit(self, sth, 'touch')
	
