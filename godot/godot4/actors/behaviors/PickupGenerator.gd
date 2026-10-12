class_name PickupGenerator extends ActorBehavior

@export var pickup_scene: PackedScene

@onready var _ctx := ArenaScope.get_scope(self)
@onready var _timer: Timer = $Timer
var _pickup_active := false
var _active_pickup: Collectable

func _ready() -> void:
	super._ready()
	_timer.timeout.connect(_on_timer_timeout)
	_timer.start()

func _spawn_pickup() -> void:
	if _pickup_active or not is_instance_valid(actor):
		return
	var pickup := pickup_scene.instantiate() as Collectable
	pickup.global_position = actor.global_position
	pickup.collected.connect(_on_pickup_collected)
	_active_pickup = pickup
	_pickup_active = true
	_ctx.spawn_request.emit(pickup)

func _on_timer_timeout() -> void:
	_spawn_pickup()
	_timer.start()

func _on_pickup_collected(_collector: PhysicsBody2D, _pickup: Collectable) -> void:
	_active_pickup = null
	_pickup_active = false

func _exit_tree() -> void:
	if is_instance_valid(_active_pickup) and not _active_pickup.is_queued_for_deletion():
		_active_pickup.queue_free()
