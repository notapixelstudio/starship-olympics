extends Control

@onready var timer = $Timer

signal over

func _input(event):
	if event.is_action_pressed("ui_accept"):
		set_process_input(false)
		await get_tree().create_timer(max(0, 1 - (timer.wait_time - timer.time_left))).timeout
		quit()
		
func _on_Timer_timeout():
	quit()

func quit():
	emit_signal("over")
