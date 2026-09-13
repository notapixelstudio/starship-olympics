@tool
extends PanelContainer

signal color_selected(color: Color)
signal canceled

const Namespace := preload("res://addons/yard/editor_only/namespace.gd")
const EditorThemeUtils := Namespace.EditorThemeUtils

var color: Color:
	set(value):
		color_picker.color = value
	get:
		return color_picker.color

@onready var color_picker: ColorPicker = %ColorPicker
@onready var select_button: Button = %SelectButton


func _ready() -> void:
	if not Engine.is_editor_hint() or EditorInterface.get_edited_scene_root() == self:
		return

	add_theme_stylebox_override(&"panel", get_theme_stylebox(&"panel", &"PopupMenu"))


func get_color_picker() -> ColorPicker:
	return color_picker


func _on_select_button_pressed() -> void:
	color_selected.emit(color_picker.color)


func _on_cancel_button_pressed() -> void:
	canceled.emit()
