extends ColorRect

signal back

onready var container = $panel/margin_container
onready var animation = $AnimationPlayer

func _ready():
	visible=true
	container.get_child(0).grab_focus()
	
	
func disable_all():
	animation.play("hide")
	yield(animation, "animation_finished")
	emit_signal("back")

func enable_all():
	animation.play("show")
	
func _input(event):
	if event.is_action_pressed("ui_back"):
		disable_all()
