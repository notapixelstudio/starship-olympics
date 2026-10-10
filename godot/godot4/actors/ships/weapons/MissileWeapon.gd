class_name MissileWeapon extends Weapon

@export var missile_scene : PackedScene
@export var offset := 50.0
@export var boost := 200
@export var charge_multiplier := 9000
@export var min_charge_for_homing_missile := 0.3

@onready var _ctx := ArenaScope.get_scope(self)

func _ready() -> void:
	get_host().release.connect(_on_release)

func _on_release(charge:float) -> void:
	fire(get_host(), charge)
	

func fire(source, charge:float):
	if not enabled:
		return
	
	var missile : Missile = missile_scene.instantiate()
	var speed := charge * charge_multiplier + boost
	missile.global_position = global_position + Vector2(offset, 0).rotated(global_rotation + PI)
	missile.set_graphics_rotation(global_rotation + PI)
	# velocity, not an impulse: Rapier drops impulses on bodies not yet in the tree (Box2D applied them twice)
	missile.linear_velocity = Vector2(speed, 0).rotated(global_rotation + PI)
	missile.set_player(source.get_player())
	missile.set_homing(charge >= min_charge_for_homing_missile)
	_ctx.spawn_request.emit(missile)
	SoundEffects.play(%FireSFX)
