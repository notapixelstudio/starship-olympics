extends Panel

@export var setting_name : String

@onready var sfx_effect  = $AudioStreamPlayer
@onready var label = %Volume
@onready var slider = %HSlider

func _ready() -> void:
	slider.value = Settings.get(setting_name)
	label.text = tr(setting_name)
	
func _on_HSlider_value_changed(new_value: int):
	Settings.set(setting_name, new_value)
	sfx_effect.play()

func _on_focus_entered() -> void:
	slider.grab_focus()

func _on_h_slider_focus_entered() -> void:
	add_theme_stylebox_override("panel", load("res://interface/themes/olympic/focus.tres"))
	label.set("theme_override_colors/font_color",Color(0,0,0))

func _on_h_slider_focus_exited() -> void:
	add_theme_stylebox_override("panel", load("res://interface/themes/olympic/normal.tres"))
	label.set("theme_override_colors/font_color", null)
