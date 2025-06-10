@tool
extends Panel

@export var setting_name : String


func _ready() -> void:
	var options = Settings.get((setting_name+'s').to_upper()).keys()
	var selected_index := -1
	var i := 0
	for option in options:
		%OptionButton.add_item(option.to_upper())
		if option == (Settings.get(setting_name) as String):
			selected_index = i
		i += 1
	%OptionButton.select(selected_index)
	%Label.set_text(setting_name.to_upper())

func _on_option_button_item_selected(index: int) -> void:
	Settings.set(setting_name, %OptionButton.get_item_text(index).to_lower())


func _on_focus_entered() -> void:
	%OptionButton.grab_focus()

func _on_option_button_focus_entered():
	add_theme_stylebox_override("panel", load("res://interface/themes/olympic/focus.tres"))
	%Label.set("theme_override_colors/font_color",Color(0,0,0))
	%OptionButton.set("theme_override_colors/font_focus_color",Color(0,0,0))
	%OptionButton.set("theme_override_colors/font_hover_color",Color(0,0,0))
	%OptionButton.set("theme_override_colors/font_hover_pressed_color",Color(0,0,0))
	%OptionButton.set("theme_override_colors/font_pressed_color",Color(0,0,0))

func _on_option_button_focus_exited():
	add_theme_stylebox_override("panel", load("res://interface/themes/olympic/normal.tres"))
	%Label.set("theme_override_colors/font_color", null)
	%OptionButton.set("theme_override_colors/font_focus_color", null)
	%OptionButton.set("theme_override_colors/font_hover_color", null)
	%OptionButton.set("theme_override_colors/font_hover_pressed_color", null)
	%OptionButton.set("theme_override_colors/font_pressed_color", null)
