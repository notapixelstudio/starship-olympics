extends Position2D

signal completed
export var speed =  4

var target
func _ready():
	set_process(false)
	deactivate()

func manual_activate(follow, start: Vector2, wait):
	position = start
	self.target = follow
	set_process(true)
	activate()
	print("will wait: "+str(wait))
	yield(get_tree().create_timer(wait), "timeout")
	manual_deactivate()
	emit_signal("completed")

func manual_deactivate():
	set_process(false)
	deactivate()
	queue_free()
	

func move(new_position: Vector2, duration: float):
	activate()
	# Move from its position to new_position
	$Tween.interpolate_property(self, "position", position, new_position, duration, Tween.TRANS_QUAD,Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	emit_signal("completed")
	

func deactivate():
	if is_in_group("in_camera"):
		remove_from_group("in_camera")
	
func activate():
	if not is_in_group("in_camera"):
		add_to_group("in_camera")

func _process(delta):
	position = lerp(position, target.position, delta*speed)
	
