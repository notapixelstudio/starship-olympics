class_name ProjectileInterception extends FamiliarBehavior

@export var recharge_seconds := 3.0
var recharge_left := 0.0

func _ready() -> void:
	$Area2D.body_entered.connect(_intercept)

func _physics_process(delta: float) -> void:
	recharge_left = maxf(0.0, recharge_left - delta)
	familiar.modulate.a = 0.25 if recharge_left > 0.0 else 1.0
	for body in $Area2D.get_overlapping_bodies():
		_intercept(body)

func _intercept(body: Node) -> void:
	if recharge_left > 0.0 or not body is Pew or body.is_queued_for_deletion():
		return
	if body.get_team() == owner_ship.get_team():
		return
	recharge_left = recharge_seconds
	body.destroy()
