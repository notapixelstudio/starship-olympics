extends Control

onready var buttons = $Buttons

func _ready():
	visible = false
	
func start():
	visible = true
	get_tree().paused = true
	yield(get_tree().create_timer(0.5), "timeout")
	buttons.enable()

func _on_Continue_pressed():
	visible = false
	buttons.disable()
	get_tree().paused = false

func _on_Restart_pressed():
	pass

func _on_QuitMatch_pressed():
	# Get back to selection screen
	get_tree().paused = false
	get_tree().reload_current_scene()
