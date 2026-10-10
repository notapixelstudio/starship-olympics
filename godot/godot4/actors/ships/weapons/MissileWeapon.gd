class_name MissileWeapon extends Weapon

@export var missile_scene : PackedScene
@export var offset := 50.0
@export var boost := 100
@export var charge_multiplier := 4500
@export var min_charge_for_homing_missile := 0.3

@onready var _ctx := ArenaScope.get_scope(self)

func _ready() -> void:
	get_host().release.connect(_on_release)

func _on_release(charge:float) -> void:
	fire(get_host(), charge)
	

func fire(source, charge:float):
	if not enabled:
		return
		
	#if %AmmoManager.is_empty():
		#return
		#
	#%AmmoManager.shot()
	
	var missile : Missile = missile_scene.instantiate()
	var impulse := charge * charge_multiplier + boost
	missile.global_position = global_position + Vector2(offset, 0).rotated(global_rotation + PI)
	missile.apply_central_impulse(Vector2(impulse, 0).rotated(global_rotation + PI))
	missile.set_player(source.get_player())
	missile.set_homing(charge >= min_charge_for_homing_missile)
	_ctx.spawn_request.emit(missile)
	
