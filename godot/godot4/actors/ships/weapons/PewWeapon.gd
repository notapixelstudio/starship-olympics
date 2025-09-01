extends Weapon

@export var pew_scene : PackedScene

func _ready() -> void:
	Events.tap.connect(_on_tap)

func _on_tap(tapper) -> void:
	if get_player() == tapper.get_player():
		fire(tapper)
	
func fire(source):
	var aperture = PI/4
	var amount = 1
	var aim_correction = 0.65
	for i in range(amount): # FIXME aim correction is not properly compatible with spreading multiple bullets (move spreading to another weapon?)
		var aim_angle : float
		var target = get_aim_compensation_target()
		if target != null:
			# correct the angle towards a target, if any was found
			aim_angle = (target.global_position - global_position).angle()
		else:
			# correct the angle according to velocity and direction
			aim_angle = (aim_correction*source.get_target_velocity().normalized() + (1-aim_correction)*Vector2.RIGHT.rotated(global_rotation)).angle() if source.get_target_velocity().length() > 0.6 else global_rotation
			
		var angle = aim_angle + ( -aperture/2 + i*aperture/(amount-1) if amount > 1 else 0)
		var pew = pew_scene.instantiate()
		pew.global_position = global_position + Vector2(120, 0).rotated(angle)
		pew.linear_velocity = Vector2(2500, 0).rotated(angle)
		pew.set_ship(source)
		Events.spawn_request.emit(pew)
		
func get_aim_compensation_target():
	for body in $"%AimCompensationZone".get_overlapping_bodies():
		# FIXME this could be abstracted in some way, not sure about traits though
		if body is Ship and get_host() is Ship and body.get_team() != get_host().get_team(): #traits.has_trait(body, 'Target'):
			return body
	return null
