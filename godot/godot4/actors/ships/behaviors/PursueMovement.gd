class_name PursueMovement extends ActorBehavior
## Chases Shapeoids first, then opposing ships, using real rigid-body collisions.

@export var force := 2000.0
@export var target_check_seconds := 0.25
@export var idle_move_seconds := 0.7
@export var idle_pause_seconds := 1.2

var owner_ship: Node2D
var target: Node2D
var _target_check_left := 0.0
var _idle_left := 0.0
var _wandering := false
var _contact_cooldowns := {}

func configure(host: Node2D, source: Node2D = null) -> void:
	super.configure(host, source)
	owner_ship = source
	actor.set_as_top_level(true)
	$ConstantForceMovement.configure(host, source)

func _ready() -> void:
	super._ready()
	owner_ship = source
	var body := actor as RigidBody2D
	if owner_ship != null:
		body.global_position = owner_ship.global_position
		if owner_ship is PhysicsBody2D:
			body.add_collision_exception_with(owner_ship)
	_idle_left = idle_pause_seconds
	$ContactArea.body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	var was_chasing := target != null
	_target_check_left -= delta
	if _target_check_left <= 0.0 or (target != null and (not is_instance_valid(target) or target.is_queued_for_deletion())):
		target = _find_target()
		_target_check_left = target_check_seconds

	if target != null:
		_wandering = false
		_idle_left = 0.0
		$ConstantForceMovement.move(actor.global_position.angle_to_point(target.global_position), force)
	else:
		if was_chasing:
			$ConstantForceMovement.move(0.0, 0.0)
			(actor as RigidBody2D).linear_velocity = Vector2.ZERO
			_idle_left = idle_pause_seconds
			_wandering = false
		_update_idle(delta)

	for body in _contact_cooldowns.keys():
		_contact_cooldowns[body] -= delta
		if _contact_cooldowns[body] <= 0.0 or not is_instance_valid(body):
			_contact_cooldowns.erase(body)
	for body in $ContactArea.get_overlapping_bodies():
		_on_body_entered(body)

func _find_target() -> Node2D:
	var enemies := get_tree().get_nodes_in_group("Shapeoid").filter(func(enemy):
		return enemy is Node2D and not enemy.is_queued_for_deletion()
	)
	if enemies.is_empty():
		enemies = get_tree().get_nodes_in_group("Ship").filter(func(ship):
			return ship != owner_ship and ship.has_method("get_team") and ship.get_team() != owner_ship.get_team()
		)
	var nearest: Node2D
	var nearest_distance := INF
	for enemy in enemies:
		var distance := actor.global_position.distance_squared_to(enemy.global_position)
		if distance < nearest_distance:
			nearest = enemy
			nearest_distance = distance
	return nearest

func _update_idle(delta: float) -> void:
	_idle_left -= delta
	if _idle_left <= 0.0:
		_wandering = not _wandering
		_idle_left = idle_move_seconds if _wandering else idle_pause_seconds
		if _wandering:
			$ConstantForceMovement.move(randf_range(-PI, PI), force * 0.45)
		else:
			$ConstantForceMovement.move(0.0, 0.0)
			(actor as RigidBody2D).linear_velocity = Vector2.ZERO

func _on_body_entered(body: Node2D) -> void:
	if body == owner_ship or _contact_cooldowns.get(body, 0.0) > 0.0:
		return
	if body is Shapeoid:
		_contact_cooldowns[body] = 0.6
		body.die(owner_ship.call("get_player") if owner_ship.has_method("get_player") else null)
	elif body is Ship and body.get_team() != owner_ship.get_team():
		_contact_cooldowns[body] = 0.6
		body.damage(actor)
