class_name ContactDamage extends FamiliarBehavior

@export var contact_cooldown := 0.5
var _contact_left := 0.0

func _ready() -> void:
	$Area2D.body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	_contact_left = maxf(0.0, _contact_left - delta)
	for body in $Area2D.get_overlapping_bodies():
		_on_body_entered(body)

func _on_body_entered(body: Node) -> void:
	if _contact_left == 0.0 and body is Ship and body != owner_ship:
		if body.get_team() != owner_ship.get_team() and not body.is_queued_for_deletion():
			_contact_left = contact_cooldown
			_damage_contact.call_deferred(body)

func _damage_contact(body: Ship) -> void:
	if is_instance_valid(body) and not body.is_queued_for_deletion():
		# Damage/cargo reactions require a rigid body as their source.
		body.damage(owner_ship)
