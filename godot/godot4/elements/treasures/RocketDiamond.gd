extends Treasure

@export var speed := 400.0
@export var steering := 10.0
@export var oscillation := 0.0

var _heading := 1

func _ready():
	if oscillation != 0.0:
		var timer = Timer.new()
		timer.wait_time = oscillation
		timer.autostart = true
		timer.timeout.connect(_on_timer_timeout)
		add_child(timer)

func _physics_process(delta):
	set_constant_force(speed*Vector2.from_angle(rotation))
	if oscillation != 0.0:
		set_constant_torque(_heading*steering)
	else:
		set_constant_torque(steering)

func _on_timer_timeout():
	_heading *= -1
