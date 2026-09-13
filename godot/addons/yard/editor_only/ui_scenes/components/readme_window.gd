@tool
extends AcceptDialog

const Namespace := preload("res://addons/yard/editor_only/namespace.gd")
const MarkdownLabel := Namespace.MarkdownLabel

@onready var markdown_label: MarkdownLabel = %MarkdownLabel


func _ready() -> void:
	if Engine.is_editor_hint():
		var mono: Font = get_theme_font(&"font", &"CodeEdit")
		markdown_label.add_theme_font_override(&"mono_font", mono)
		markdown_label.add_theme_color_override(&"table_even_row_bg", get_theme_color(&"prop_section", &"Editor"))
		markdown_label.add_theme_color_override(&"table_odd_row_bg", get_theme_color(&"separator_color", &"Editor"))
		markdown_label.h2.font_color = get_theme_color(&"accent_color", &"Editor")
		markdown_label.h3.font_color = get_theme_color(&"font_focus_color", &"Editor")

		#markdown_label.display_file()
