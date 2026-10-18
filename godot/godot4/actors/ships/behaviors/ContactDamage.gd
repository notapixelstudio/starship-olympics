class_name ContactDamage extends FamiliarTrait
## Hits enemy ships (with a cooldown) and destroys Shapeoids such as Bloids on touch.

@export var contact_cooldown := 0.5
var _contact_left := 0.0

func _ready() -> void:
	super._ready()
	$Area2D.body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	_contact_left = maxf(0.0, _contact_left - delta)
	for body in $Area2D.get_overlapping_bodies():
		_on_body_entered(body)

func _on_body_entered(body: Node) -> void:
	if body is Shapeoid and not body.is_queued_for_deletion():
		body.kill(familiar.get_player()) # not deferred: queued at once, so the overlap loop cannot score it twice
		Events.log.emit("[b]%s[/b] destroyed [b]%s[/b]" % [familiar.describe(), body.name])
	elif _contact_left == 0.0 and body is Ship:
		if body.get_team() != familiar.get_team() and not body.is_queued_for_deletion():
			_contact_left = contact_cooldown
			_damage_contact.call_deferred(body)

func _damage_contact(body: Ship) -> void:
	if is_instance_valid(body) and not body.is_queued_for_deletion():
		body.hit(familiar)
