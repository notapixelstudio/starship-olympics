class_name ThrowableMovement extends FamiliarBehavior

enum State { FOLLOWING, THROWN, RETURNING }

@export var throw_speed := 900.0
@export var return_speed := 1200.0

var state := State.FOLLOWING
var _direction := Vector2.RIGHT
var _throw_left := 0.0

func _ready() -> void:
	owner_ship.tap.connect(_on_tap)
	$Area2D.body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if state == State.THROWN:
		var destination := familiar.global_position + _direction * throw_speed * delta
		var query := PhysicsRayQueryParameters2D.create(familiar.global_position, destination, 16)
		query.exclude = [owner_ship.get_rid()]
		var hit := get_world_2d().direct_space_state.intersect_ray(query)
		if hit:
			familiar.global_position = hit.position + hit.normal * 2.0
			_begin_return()
		else:
			familiar.global_position = destination
	elif state == State.RETURNING:
		familiar.global_position = familiar.global_position.move_toward(owner_ship.global_position, return_speed * delta)
		if familiar.global_position.distance_squared_to(owner_ship.global_position) < 144.0:
			state = State.FOLLOWING
			$"../FollowMovement".active = true

func _on_tap(_charge: float) -> void:
	if state != State.FOLLOWING:
		return
	$"../FollowMovement".active = false
	_direction = Vector2.RIGHT.rotated(owner_ship.global_rotation)
	familiar.global_position = owner_ship.global_position + _direction * 60.0
	state = State.THROWN

func _on_body_entered(body: Node) -> void:
	if state != State.THROWN or not body is Ship or body == owner_ship or body.is_queued_for_deletion():
		return
	if body.get_team() == owner_ship.get_team():
		return
	_begin_return()
	_damage_contact.call_deferred(body)

func _begin_return() -> void:
	state = State.RETURNING

func _damage_contact(body: Ship) -> void:
	if is_instance_valid(body) and not body.is_queued_for_deletion():
		body.damage(owner_ship)
