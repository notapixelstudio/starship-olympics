@tool
extends CheckBox

@export var setting_name : String

var _silent := true

func _ready() -> void:
	set_pressed(Settings.get(setting_name) as bool)
	set_text(setting_name.to_upper())
	
	# start without sound to disable audio feedback on appearing
	await get_tree().process_frame
	_silent = false

func _on_toggled(toggled_on: bool) -> void:
	Settings.set(setting_name, toggled_on)
	if toggled_on:
		%enable_sfx.play()
	else:
		%disable_sfx.play()


func _on_focus_entered():
	set("theme_override_colors/font_focus_color",Color(0,0,0))
	set("theme_override_colors/font_hover_color",Color(0,0,0))
	set("theme_override_colors/font_hover_pressed_color",Color(0,0,0))
	set("theme_override_colors/font_pressed_color",Color(0,0,0))
	if not _silent:
		%focus_sfx.play()

func _on_focus_exited():
	set("theme_override_colors/font_focus_color", null)
	set("theme_override_colors/font_hover_color", null)
	set("theme_override_colors/font_hover_pressed_color", null)
	set("theme_override_colors/font_pressed_color", null)
