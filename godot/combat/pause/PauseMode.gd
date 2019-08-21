extends Control

onready var buttons = $GuiElements/Buttons
onready var pause_window = $Window
onready var gui = $GuiElements
var unpause_ready = false

signal back_to_menu
signal restart
signal skip

func _ready():
	gui.visible = false
	visible = false
	
	
func start():
	$Tween.interpolate_property(pause_window, "scale", Vector2(0.75,0), Vector2(0.75, 0.75), 0.15, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
	visible = true
	get_tree().paused = true
	yield($Tween, "tween_completed")
	gui.visible = true
	buttons.enable()
	unpause_ready = true

func _unhandled_input(event):
	if unpause_ready and event.is_action_pressed("pause"):
		unpause()
		
	
func _on_Continue_pressed():
	unpause()
	
func unpause():
	$Tween.interpolate_property(pause_window, "scale", Vector2(0.75,0.75), Vector2(0.75, 0), 0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
	buttons.disable()
	gui.visible = false
	yield($Tween, "tween_completed")
	visible = false
	unpause_ready = false
	get_tree().paused = false

func _on_Restart_pressed():
	print("restarto")
	emit_signal("restart")
	
func _on_SkipLevel_pressed():
	print("skipo")
	emit_signal("skip")
	
func _on_QuitMatch_pressed():
	# Get back to selection screen
	get_tree().paused = false
	emit_signal("back_to_menu")
