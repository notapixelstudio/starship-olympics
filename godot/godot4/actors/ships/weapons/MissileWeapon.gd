class_name MissileWeapon extends Weapon

@export var missile_scene : PackedScene
@export var offset := 120.0

@onready var _ctx := ArenaScope.get_scope(self)

func _ready() -> void:
	get_host().tap.connect(_on_tap)

func _on_tap(charge:float) -> void:
	fire(get_host())
	
func fire(source):
	if not enabled:
		return
		
	if %AmmoManager.is_empty():
		return
		
	%AmmoManager.shot()
	
	var missile : Missile = missile_scene.instantiate()
	missile.global_position = global_position + Vector2(offset, 0).rotated(PI)
	missile.linear_velocity = Vector2(2500, 0).rotated(PI)
	#missile.set_color(source.get_color())
	#missile.set_team(source.get_team())
	_ctx.spawn_request.emit(missile)
	
