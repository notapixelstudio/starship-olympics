extends ColorRect

var array_songs

signal back

onready var container = $panel/margin_container/v_box_container
onready var animation = $AnimationPlayer

func _ready():
	enable_all()
	visible=true
	
func disable_all():
	animation.play("hide")
	yield(animation, "animation_finished")
	emit_signal("back")

func enable_all():
	animation.play("show")
	container.get_child(1).grab_focus()
	yield(animation, "animation_finished")
	
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		disable_all()

func _exit_tree():
	# Let's save the changes
	persistance.save_game()