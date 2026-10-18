class_name PursueMovement extends FamiliarTrait
## Chases Shapeoids first, then opposing ships, using real rigid-body collisions.

@export var force := 2000.0
@export var target_check_seconds := 0.25
@export var idle_move_seconds := 0.7
@export var idle_pause_seconds := 1.2

var target: Node2D
var _target_check_left := 0.0
var _idle_left := 0.0
var _wandering := false
var _contact_cooldowns := {}

func validate():
	super.validate()
	assert(not host.freeze) # pushes with forces

func _ready() -> void:
	super._ready()
	_idle_left = idle_pause_seconds
	$ContactArea.body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if owner_ship == null:
		return
	var was_chasing := target != null
	_target_check_left -= delta
	if _target_check_left <= 0.0 or (target != null and (not is_instance_valid(target) or target.is_queued_for_deletion())):
		target = _find_target()
		_target_check_left = target_check_seconds

	if target != null:
		_wandering = false
		_idle_left = 0.0
		familiar.set_constant_force(familiar.global_position.direction_to(target.global_position) * force)
	else:
		if was_chasing:
			familiar.set_constant_force(Vector2.ZERO)
			familiar.linear_velocity = Vector2.ZERO
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
			return ship.has_method("get_team") and ship.get_team() != familiar.get_team()
		)
	var nearest: Node2D
	var nearest_distance := INF
	for enemy in enemies:
		var distance := familiar.global_position.distance_squared_to(enemy.global_position)
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
			familiar.set_constant_force(Vector2.RIGHT.rotated(randf_range(-PI, PI)) * force * 0.45)
		else:
			familiar.set_constant_force(Vector2.ZERO)
			familiar.linear_velocity = Vector2.ZERO

func _on_body_entered(body: Node2D) -> void:
	if _contact_cooldowns.get(body, 0.0) > 0.0:
		return
	if body is Shapeoid:
		_contact_cooldowns[body] = 0.6
		body.kill(familiar.get_player())
		Events.log.emit("[b]%s[/b] destroyed [b]%s[/b]" % [familiar.describe(), body.name])
	elif body is Ship and body.get_team() != familiar.get_team():
		_contact_cooldowns[body] = 0.6
		body.hit(familiar)
