extends Control

onready var buttons = $GuiElements/Buttons
onready var pause_window = $Window
onready var gui = $GuiElements

func _ready():
	gui.visible = false
	visible = false
	
	
func start():
	$Tween.interpolate_property(pause_window, "scale", Vector2(0.75,0), Vector2(0.75, 0.75), 0.15,
	 Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
	visible = true
	get_tree().paused = true
	yield($Tween, "tween_completed")
	gui.visible = true
	buttons.enable()


func _on_Continue_pressed():
	$Tween.interpolate_property(pause_window, "scale", Vector2(0.75,0.75), Vector2(0.75, 0), 0.1,
	 Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
	buttons.disable()
	gui.visible = false
	yield($Tween, "tween_completed")
	visible = false
	get_tree().paused = false

func _on_Restart_pressed():
	pass

func _on_QuitMatch_pressed():
	# Get back to selection screen
	get_tree().paused = false
	get_tree().reload_current_scene()
