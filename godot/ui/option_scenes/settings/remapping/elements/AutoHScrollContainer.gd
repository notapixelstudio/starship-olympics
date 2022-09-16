extends Control

var operator = 50
@onready var buttons = $MarginContainer/Buttons
@onready var destination = size.x - buttons.size.x

@export var button_scene: PackedScene
func calculate_dist(x, y):
	if x > y:
		return 0
	else:
		return x-y
		
func _ready():
	await get_tree().create_timer(0.3).timeout
	var anim = $AnimationPlayer.get_animation('Scroll')
	anim.resource_local_to_scene = true
	var dest = calculate_dist(size.x, buttons.size.x)
	anim.track_set_key_value(0, 0, dest)
	anim.track_set_key_value(0, 2, dest)
	$AnimationPlayer.play("Scroll")

func get_elements() -> Array:
	return buttons.get_children()
	
func add_event(new_event: InputEvent):
	var button: ButtonRepresentation = button_scene.instantiate()
	if button.set_button(new_event):
		buttons.add_child(button)
	
	await get_tree().idle_frame
	
	var anim = $AnimationPlayer.get_animation('Scroll')
	var dest = calculate_dist(size.x, buttons.size.x)
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
		b.hide()
		b.queue_free()
	await get_tree().idle_frame
	buttons.size = size
	var dest = calculate_dist(size.x, buttons.size.x)
	var anim = $AnimationPlayer.get_animation('Scroll')
	anim.track_set_key_value(0, 0, 0)
	anim.track_set_key_value(0, 2, 0)
	
