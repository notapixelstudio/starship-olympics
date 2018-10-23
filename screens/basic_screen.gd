extends Control
enum trans_type{IN, OUT}
export (String, FILE, "*.tscn") var next_scene
signal transition_finished

func _input(event):
	pass


func _ready():
	$Transition/ColorRect.rect_size = get_viewport().size + Vector2(20, 20)
	$Transition/ColorRect.rect_position = Vector2()
	#Transition back everytime a screen is loaded
	apply_transition(OUT)
	
func change_scene(to = next_scene):
	#Applies an transition animation then load the next scene
	set_process_input(false)
	apply_transition(IN)
	yield(self, "transition_finished")
	get_tree().change_scene(to)
	
func apply_transition(mode):
	#Verifies which kind of transition to be used, IN or OUT then plays
	#the animation forward or backwards then emits a signal for completion
	var a = $Animator
	if mode == 0:
		a.play("transition")
	else:
		a.play_backwards("transition")
	yield(a, "animation_finished")
	emit_signal("transition_finished")