extends Turret
class_name RotoTurret

@export_range(-360*10, 360*10, 0.5, "radians_as_degrees", "suffix:deg/s") var rotation_speed := PI/8
@export var starting_angles_degrees := [45,45+90,45+180,45+270]

func _ready() -> void:
	set_physics_process(false)
	rotation_degrees = starting_angles_degrees.pick_random()
	
func start() -> void:
	super.start()
	set_physics_process(true)
	
func _physics_process(delta: float) -> void:
	rotation += delta * rotation_speed
