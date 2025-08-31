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
	for i in range(amount):
		var aim_angle = (aim_correction*source.get_target_velocity().normalized() + (1-aim_correction)*Vector2.RIGHT.rotated(global_rotation)).angle() if source.get_target_velocity().length() > 0.6 else global_rotation
		var angle = aim_angle + ( -aperture/2 + i*aperture/(amount-1) if amount > 1 else 0)
		var pew = pew_scene.instantiate()
		pew.global_position = global_position + Vector2(120, 0).rotated(angle)
		pew.linear_velocity = Vector2(2500, 0).rotated(angle)
		pew.set_ship(source)
		Events.spawn_request.emit(pew)
		
##
#if bomb_type == GameMode.BOMB_TYPE.fw_pew and not $'%Ammo'.is_empty():# and not is_hiding():
	#$'%Ammo'.shot()
	#var aperture = PI/4
	#var amount = 1
	#var aim_correction = 0.65
	#var aim_angle = (aim_correction*get_target_velocity().normalized() + (1-aim_correction)*Vector2.RIGHT.rotated(global_rotation)).angle() if get_target_velocity().length() > 0.6 else global_rotation
	#var target = get_aim_adjusting_target()
	#if target != null:
		#aim_angle = (target.global_position - global_position).angle()
	#for i in range(amount):
		#var angle = aim_angle + ( -aperture/2 + i*aperture/(amount-1) if amount > 1 else 0)
		#var bullet = forward_bullet_scene.instantiate()
		#get_parent().add_child(bullet)
		#bullet.global_position = global_position + Vector2(120, 0).rotated(angle)
		#bullet.linear_velocity = Vector2(2500, 0).rotated(angle)
		#bullet.set_ship(self)
			
#func get_aim_adjusting_target():
	#for body in $"%FwShotCompensationZone".get_overlapping_bodies():
		#if body != self and traits.has_trait(body, 'Target'):
			#return body
	#return null
