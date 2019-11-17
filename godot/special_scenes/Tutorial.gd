extends Control

signal over

func _ready():
	set_process_input(false)
	yield(get_tree().create_timer(2), "timeout")
	set_process_input(true)
	
func _input(event):
	if event.is_action_pressed("ui_accept"):
		delete_and_quit()
		
func _on_Timer_timeout():
	delete_and_quit()

func delete_and_quit():
	emit_signal("over")
	queue_free()