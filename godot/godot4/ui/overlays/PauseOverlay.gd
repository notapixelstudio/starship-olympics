extends Control

@export var in_match = true
@export var map_texture : Texture2D

@onready var buttons = $GuiElements/VBoxContainer/Buttons
@onready var pause_window = $Window
@onready var gui = $GuiElements
var paused = false

var _minigame : Minigame

signal restart
signal skip

func _ready():
	if not _minigame:
		%Minigame.modulate = Color(0,0,0,0)
		%Description.modulate = Color(0,0,0,0)
	
	# hide buttons that are relevant only during matches
	if not in_match:
		$GuiElements/VBoxContainer/Buttons/Restart.queue_free()
		$GuiElements/VBoxContainer/Buttons/SkipLevel.queue_free()
		$GuiElements/VBoxContainer/Buttons/Quit1.queue_free()
		$Window.texture = map_texture
	else:
		await get_tree().process_frame # wait for match to be set up
		#$GuiElements/VBoxContainer/Minigame.text = global.the_match.get_game_mode().name
		#$GuiElements/VBoxContainer/Description.text = global.the_match.get_game_mode().description
	
func pause():
	#$Tween.interpolate_property(pause_window, "scale", Vector2(0.75,0), Vector2(0.75, 0.75), 0.15, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	#$Tween.start()
	visible = true
	get_tree().paused = true
	#await $Tween.tween_completed
	gui.visible = true
	buttons.enable()
	paused = true
	#raise()

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		if paused:
			unpause()
		else:
			pause()
		
	
func _on_Continue_pressed():
	unpause()
	
func unpause():
	#$Tween.interpolate_property(pause_window, "scale", Vector2(0.75,0.75), Vector2(0.75, 0), 0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	#$Tween.start()
	buttons.disable()
	gui.visible = false
	#await $Tween.tween_completed
	visible = false
	paused = false
	get_tree().paused = false

func _on_Restart_pressed():
	get_tree().paused = false
	emit_signal("restart")
	
func _on_SkipLevel_pressed():
	get_tree().paused = false
	#global.safe_destroy_match()
	Events.emit_signal("continue_after_game_over", false)
	
func _on_Quit1_pressed():
	get_tree().paused = false
	Events.emit_signal("nav_to_map")
	
func _on_Quit2_pressed():
	get_tree().paused = false
	Events.emit_signal("nav_to_character_selection")
	
func _on_Quit3_pressed():
	get_tree().paused = false
	Events.emit_signal("nav_to_menu")

func set_minigame(value: Minigame):
	_minigame = value
	%Minigame.text = _minigame.title.to_upper()
	%Description.text = _minigame.description.to_upper()
	%Minigame.modulate = Color.WHITE
	%Description.modulate = Color.WHITE
	
