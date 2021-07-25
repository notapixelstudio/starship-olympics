extends Control

export var in_match = true

onready var buttons = $GuiElements/Buttons
onready var pause_window = $Window
onready var gui = $GuiElements
var unpause_ready = false

signal restart
signal skip

func _ready():
	gui.visible = false
	visible = false
	
	# hide buttons that are relevant only during matches
	if not in_match:
		$GuiElements/Buttons/Restart.queue_free()
		$GuiElements/Buttons/SkipLevel.queue_free()
		$GuiElements/Buttons/Quit1.queue_free()
	
func start():
	$Tween.interpolate_property(pause_window, "scale", Vector2(0.75,0), Vector2(0.75, 0.75), 0.15, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
	visible = true
	get_tree().paused = true
	yield($Tween, "tween_completed")
	gui.visible = true
	buttons.enable()
	unpause_ready = true
	raise()

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
	get_tree().paused = false
	emit_signal("restart")
	
func _on_SkipLevel_pressed():
	get_tree().paused = false
	emit_signal("skip")
	
func _on_Quit1_pressed():
	get_tree().paused = false
	Events.emit_signal("nav_to_map")
	
func _on_Quit2_pressed():
	get_tree().paused = false
	Events.emit_signal("nav_to_character_selection")
	
func _on_Quit3_pressed():
	get_tree().paused = false
	Events.emit_signal("nav_to_menu")
