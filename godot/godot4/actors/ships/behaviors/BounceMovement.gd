class_name BounceMovement extends FamiliarTrait
## Bounces off whatever it hits to its own speed, physics handles the direction

@export var speed := 700.0
@export var contact_cooldown := 0.5

var _contact_time := {}

func validate():
	super.validate()
	assert(not host.freeze) # bounces via physics

func _ready() -> void:
	super._ready()
	familiar.linear_velocity = _random_diagonal_velocity()
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

	if owner_ship == null:
		return
	var velocity := familiar.linear_velocity
	familiar.linear_velocity = _random_diagonal_velocity() if velocity.is_zero_approx() else velocity.normalized() * speed

func _on_body_entered(body: Node) -> void:
	if body is Ship and body.get_team() != familiar.get_team():
		if _contact_time.get(body, 0.0) == 0.0 and not body.is_queued_for_deletion():
			_contact_time[body] = contact_cooldown
			_damage_contact.call_deferred(body)

func _damage_contact(body: Ship) -> void:
	if is_instance_valid(body) and not body.is_queued_for_deletion():
		body.hit(familiar)
