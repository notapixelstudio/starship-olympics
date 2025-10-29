extends Turret
class_name RotoTurret

@export_range(-360*10, 360*10, 0.5, "radians_as_degrees", "suffix:deg/s") var rotation_speed := PI/8

@export var starting_angles_degrees := [45,45+90,45+180,45+270]
@export var time_offset := -0.5

@export var clockwise := true

@export_group("Pingpong")
@export var pingpong := false
@export_range(-360,360, 1, "radians_as_degrees", "suffix:deg") var min_rotation := 0.0
@export_range(-360,360, 1, "radians_as_degrees", "suffix:deg") var max_rotation := TAU

func _ready() -> void:
	set_process(false)
	rotation_degrees = starting_angles_degrees.pick_random()
	
	# start slightly back to allow for animation timing compensation
	rotation += rotation_speed * time_offset * (1.0 if clockwise else -1.0)
	
func start() -> void:
	super.start()
	set_process(true)
	
func _process(delta: float) -> void:
	rotation += delta * rotation_speed * (1.0 if clockwise else -1.0)
	
	if pingpong:
		if clockwise and rotation >= max_rotation:
			clockwise = false
			rotation -= rotation - max_rotation # wind a bit back
		elif not clockwise and rotation <= min_rotation:
			clockwise = true
			rotation += min_rotation - rotation # wind a bit forward
