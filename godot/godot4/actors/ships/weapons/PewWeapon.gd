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
		source.get_parent().add_child(pew)
		pew.set_ship(source)
