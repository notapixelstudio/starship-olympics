extends Panel

@export var setting_name : String

@onready var sfx_effect  = $AudioStreamPlayer
@onready var label = %Volume
@onready var slider = %HSlider

var _silent := true

func _ready() -> void:
	slider.value = Settings.get(setting_name)
	label.text = tr(setting_name)
	
	# start without sound to disable audio feedback on appearing
	await get_tree().process_frame
	_silent = false
	
func _on_HSlider_value_changed(new_value: int):
	Settings.set(setting_name, new_value)
	if not _silent:
		sfx_effect.play()

func _on_focus_entered() -> void:
	slider.grab_focus()

func _on_h_slider_focus_entered() -> void:
	add_theme_stylebox_override("panel", load("res://interface/themes/olympic/focus.tres"))
	label.set("theme_override_colors/font_color",Color(0,0,0))
	if not _silent:
		%focus_sfx.play()

func _on_h_slider_focus_exited() -> void:
	add_theme_stylebox_override("panel", load("res://interface/themes/olympic/normal.tres"))
	label.set("theme_override_colors/font_color", null)
