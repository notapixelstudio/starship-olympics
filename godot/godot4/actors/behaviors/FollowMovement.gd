class_name FollowMovement extends ActorBehavior

@export var follow_distance := 300.0
@export var follow_speed := 8.0
var follow_target: Node2D
var _follow_position := Vector2.ZERO
var active := true

func configure(host: Node2D, source: Node2D = null) -> void:
	super.configure(host, source)
	if host is Familiar and host.previous_same_scene != null:
		follow_target = host.previous_same_scene
	else:
		follow_target = source

func _ready() -> void:
	super._ready()
	if follow_target == null:
		follow_target = source
	_follow_position = follow_target.global_position - Vector2.RIGHT.rotated(source.global_rotation) * follow_distance
	actor.global_position = _follow_position

func _physics_process(delta: float) -> void:
	if not active:
		return
	if not is_instance_valid(follow_target):
		return
	var offset := _follow_position - follow_target.global_position
	if offset.length() > follow_distance:
		var destination := follow_target.global_position + offset.normalized() * follow_distance
		_follow_position = _follow_position.lerp(destination, 1.0 - exp(-follow_speed * delta))
	actor.global_position = _follow_position
	actor.global_rotation = source.global_rotation
