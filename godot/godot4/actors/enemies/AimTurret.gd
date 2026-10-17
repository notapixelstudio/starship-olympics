extends Turret
class_name AimTurret

@export var aim_speed := 8.0
@export var predictive_aim := 0.7

var _compensate := true
var _targets : Array[Node] = []

func set_targets(v:Array[Node]) -> void:
	_targets = v

func fire() -> void:
	# sometimes the aim compensates for target's movement, sometimes not
	_compensate = randf() > 0.33
	
	super()

func _physics_process(delta: float) -> void:
	if len(_targets) <= 0:
		return
		
	# aim to first available target
	var target = _targets[0] # TBD random preference
	
	if not target or not is_instance_valid(target):
		return
		
	var compensation = Vector2.ZERO
	if _compensate:
		compensation = target.linear_velocity*predictive_aim
		
	%Weapons.global_rotation = lerp_angle(%Weapons.global_rotation, global_position.angle_to_point(target.global_position + compensation), delta*aim_speed)
	
