@tool
extends HBoxContainer

@export var setting_name : String


func _ready() -> void:
	var options = Settings.get((setting_name+'s').to_upper()).keys()
	var selected_index := -1
	var i := 0
	for option in options:
		%OptionButton.add_item(option)
		if option == (Settings.get(setting_name) as String):
			selected_index = i
		i += 1
	%OptionButton.select(selected_index)
	%Label.set_text(setting_name)

func _on_option_button_item_selected(index: int) -> void:
	Settings.set(setting_name, %OptionButton.get_item_text(index))
