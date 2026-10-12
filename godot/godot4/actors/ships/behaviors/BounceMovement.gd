class_name BounceMovement extends FamiliarBehavior

@export var speed := 700.0
@export var contact_cooldown := 0.5

var velocity := Vector2.ZERO
var _contact_time := {}

func configure(root: Node2D, owner: Node2D = null) -> void:
	super.configure(root, owner)
	if root is Familiar:
		root.set_as_top_level(true)

func _ready() -> void:
	familiar.global_position = owner_ship.global_position
	velocity = _random_diagonal_velocity()
	$Area2D.body_entered.connect(_on_body_entered)

func _random_diagonal_velocity() -> Vector2:
	var quadrant := randi_range(0, 3)
	var angle := quadrant * PI / 2 + randf_range(PI / 6, PI / 3)
	return Vector2.from_angle(angle) * speed

func _physics_process(delta: float) -> void:
	for body in _contact_time.keys():
		_contact_time[body] = maxf(0.0, _contact_time[body] - delta)
		if _contact_time[body] == 0.0:
			_contact_time.erase(body)
	for body in $Area2D.get_overlapping_bodies():
		_on_body_entered(body)

	var destination := familiar.global_position + velocity * delta
	var query := PhysicsRayQueryParameters2D.create(familiar.global_position, destination, 16)
	query.exclude = [owner_ship.get_rid()]
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	if hit:
		familiar.global_position = hit.position + hit.normal * 2.0
		velocity = velocity.bounce(hit.normal).normalized() * speed
	else:
		familiar.global_position = destination

func _on_body_entered(body: Node) -> void:
	if body is Ship and body != owner_ship and body.get_team() != owner_ship.get_team():
		if _contact_time.get(body, 0.0) == 0.0 and not body.is_queued_for_deletion():
			_contact_time[body] = contact_cooldown
			_damage_contact.call_deferred(body)

func _damage_contact(body: Ship) -> void:
	if is_instance_valid(body) and not body.is_queued_for_deletion():
		body.damage(owner_ship)
