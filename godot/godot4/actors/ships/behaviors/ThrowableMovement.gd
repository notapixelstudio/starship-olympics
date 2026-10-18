class_name ThrowableMovement extends FamiliarTrait
## On the ship's tap, flies forward until it hits something, then boomerangs back through walls.

enum State { FOLLOWING, THROWN, RETURNING }

@export var throw_speed := 900.0
@export var return_speed := 1200.0

var state := State.FOLLOWING
var _direction := Vector2.RIGHT
var _mask := 0
var _follow: FollowMovement

func validate():
	super.validate()
	assert(host.has_node(^"FollowMovement")) # follows between throws

func _ready() -> void:
	super._ready()
	_follow = familiar.get_node(^"FollowMovement")
	_mask = familiar.collision_mask
	familiar.tap.connect(_on_tap)
	familiar.body_entered.connect(func(_body): if state == State.THROWN: _begin_return())
	$Area2D.body_entered.connect(_on_body_entered)

func _physics_process(_delta: float) -> void:
	if state == State.THROWN:
		familiar.linear_velocity = _direction * throw_speed
	elif state == State.RETURNING:
		var ship := owner_ship
		if ship == null:
			_end_return() # the ship is gone: coast with the rest of the chain
			return
		var to := ship.global_position - familiar.global_position
		familiar.linear_velocity = to.normalized() * return_speed
		if to.length_squared() < 3600.0:
			_end_return()

func _on_tap(_charge: float) -> void:
	if state != State.FOLLOWING:
		return
	var ship := owner_ship
	_follow.set_physics_process(false)
	_direction = Vector2.RIGHT.rotated(ship.global_rotation)
	familiar.global_position = ship.global_position + _direction * 60.0
	state = State.THROWN

func _on_body_entered(body: Node) -> void:
	if state != State.THROWN or not body is Ship or body.is_queued_for_deletion():
		return
	if body.get_team() == familiar.get_team():
		return
	_begin_return()
	_damage_contact.call_deferred(body)

func _begin_return() -> void:
	state = State.RETURNING
	familiar.collision_mask = 0

func _end_return() -> void:
	state = State.FOLLOWING
	familiar.collision_mask = _mask
	_follow.set_physics_process(true)

func _damage_contact(body: Ship) -> void:
	if is_instance_valid(body) and not body.is_queued_for_deletion():
		body.hit(familiar)
