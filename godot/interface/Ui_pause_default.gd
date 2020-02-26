extends ColorRect

var array_songs

signal back

onready var container = $Panel/PanelItems/Items
onready var animation = $AnimationPlayer

var focus_index = 0


func disable_all():
	animation.play("hide")
	yield(animation, "animation_finished")
	emit_signal("back")
	visible = false

func enable_all():
	visible = true
	for elem in container.get_children():
		elem._initialize()
	focus_index = 0
	container.get_child(focus_index).grab_focus()
	
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		container.get_child(container.get_child_count()-1).grab_focus()
		disable_all()
	if event.is_action_pressed("ui_up"):
		focus_index = clamp(focus_index-1, 0, container.get_child_count() -1)
		#container.get_child(focus_index).grab_focus()
		
	if event.is_action_pressed("ui_down"):
		focus_index = clamp(focus_index+1, 0, container.get_child_count() -1)
		#container.get_child(focus_index).grab_focus()
		
	

func _exit_tree():
	# Let's save the changes
	persistance.save_game()

func _on_Button_pressed():
	disable_all()
