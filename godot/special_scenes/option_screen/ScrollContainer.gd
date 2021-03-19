extends Control

var operator = 50
onready var buttons = $Buttons
onready var destination = rect_size.x - buttons.rect_size.x

func calculate_dist(x, y):
	if x > y:
		return 0
	else:
		return x-y
		
func _ready():
	yield(get_tree().create_timer(0.3), "timeout")
	var anim = $AnimationPlayer.get_animation('Scroll')
	var dest = calculate_dist(rect_size.x, buttons.rect_size.x)
	anim.track_set_key_value(0, 0, dest)
	anim.track_set_key_value(0, 2, dest)
	$AnimationPlayer.play("Scroll")
	
func add_element(element: Control):
	buttons.add_child(element)
	yield(get_tree().create_timer(0.3), "timeout")
	
	var anim = $AnimationPlayer.get_animation('Scroll')
	var dest = calculate_dist(rect_size.x, buttons.rect_size.x)
	anim.track_set_key_value(0, 0, dest)
	anim.track_set_key_value(0, 2, dest)
	$AnimationPlayer.stop()
	$AnimationPlayer.play("Scroll")
	var speed = 1
	if dest != 0:
		speed = min(-100/dest, 1)
	$AnimationPlayer.playback_speed = speed
	
	
func clear():
	for b in buttons.get_children():
		b.queue_free()
	yield(get_tree().create_timer(0.4), "timeout")
	buttons.rect_size = rect_size
	print(buttons.rect_size)
	var dest = calculate_dist(rect_size.x, buttons.rect_size.x)
	var anim = $AnimationPlayer.get_animation('Scroll')
	anim.track_set_key_value(0, 0, 0)
	anim.track_set_key_value(0, 2, 0)
	
		
