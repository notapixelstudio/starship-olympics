@tool
extends CheckBox

@export var setting_name : String

func _ready() -> void:
	set_pressed(Settings.get(setting_name) as bool)
	set_text(setting_name)

func _on_toggled(toggled_on: bool) -> void:
	Settings.set(setting_name, toggled_on)
