extends Control

onready var timer = $Timer

signal over

func _input(event):
	if event.is_action_pressed("ui_fire"):
		set_process_input(false)
		yield(get_tree().create_timer(max(0, 0.5 - (timer.wait_time - timer.time_left))), "timeout")
		delete_and_quit()
		
func _on_Timer_timeout():
	delete_and_quit()

func delete_and_quit():
	emit_signal("over")
	queue_free()
