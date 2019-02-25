extends ColorRect

var array_songs

signal back

onready var container = $panel/margin_container/v_box_container
onready var animation = $AnimationPlayer

func _ready():
	visible=true
	enable_all()
	array_songs = Soundtrack.array_songs
	
func disable_all():
	animation.play("hide")
	yield(animation, "animation_finished")
	emit_signal("back")

func enable_all():
	animation.play("show")
	container.get_child(1).grab_focus()
	yield(animation, "animation_finished")

	
func _input(event):
	if event.is_action_pressed("ui_back"):
		disable_all()
