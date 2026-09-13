## Source: String Wrangler
## Created by Matthew Janes (IndieGameDad) - MIT 2025

@tool
extends EditorProperty

var inner_control: OptionButton
var show_empty: bool = false
var string_type: Variant.Type # TYPE_STRING or TYPE_STRING_NAME


func _init(current_value: Variant, string_ids: Array[String], p_show_empty: bool = false, p_type: Variant.Type = TYPE_STRING) -> void:
	string_type = p_type
	inner_control = _build_dropdown(string_ids, str(current_value), p_show_empty)
	show_empty = p_show_empty
	add_child(inner_control)
	inner_control.item_selected.connect(_on_option_selected)


func _build_dropdown(choices: Array[String], current_value: String, p_show_empty: bool) -> OptionButton:
	var dropdown: OptionButton = OptionButton.new()
	dropdown.flat = true
	dropdown.fit_to_longest_item = false
	dropdown.allow_reselect = true
	dropdown.clip_text = true

	if p_show_empty:
		dropdown.add_item("<empty>")

	for choice in choices:
		dropdown.add_item(choice)

	var offset: int = 1 if p_show_empty else 0
	for i in range(offset, dropdown.item_count):
		if dropdown.get_item_text(i) == current_value:
			dropdown.select(i)
			break

	return dropdown


func _on_option_selected(index: int) -> void:
	var raw: String = "" if show_empty and index == 0 else inner_control.get_item_text(index)
	@warning_ignore("incompatible_ternary")
	var value: Variant = StringName(raw) if string_type == TYPE_STRING_NAME else raw
	emit_changed(get_edited_property(), value)


func _update_property() -> void:
	var current: String = get_edited_object().get(get_edited_property())

	inner_control.select(-1)
	for i in range(inner_control.item_count):
		if inner_control.get_item_text(i) == current:
			inner_control.select(i)
			break

	inner_control.text = current
