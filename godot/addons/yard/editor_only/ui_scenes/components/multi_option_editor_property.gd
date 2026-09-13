## Source: String Wrangler
## Created by Matthew Janes (IndieGameDad) - MIT 2025

## A generic editor property for selecting multiple string options.
## Dynamically disables already-selected entries and supports clean UI expansion.
@tool
extends EditorProperty

var available_options: Array[String] = []
var selected_options: Array[String] = []

var is_expanded: bool = false
var _refreshing: bool = false

var fold_button: Button
var dropdown_container: PanelContainer

var list_display_name: String = ""
var include_duplicates: bool = false
var element_type: Variant.Type = TYPE_STRING


## Initializes the editor with a list of selectable values and currently selected items.
func initialize(initial_values: Array[Variant], options: Array[Variant], list_name: String = "StringList", allow_duplicates: bool = false, p_type: Variant.Type = TYPE_STRING) -> void:
	element_type = p_type
	available_options = options.duplicate()
	selected_options.clear()

	list_display_name = list_name
	include_duplicates = allow_duplicates

	selected_options.clear()

	# Track seen values for uniqueness enforcement
	var seen: Dictionary = { }

	for item: Variant in initial_values:
		var as_string: String = str(item)
		if not available_options.has(as_string):
			continue
		if not include_duplicates:
			if seen.has(as_string):
				continue
			seen[as_string] = true
		selected_options.append(as_string)

	# Trim the list to the max number of available options if duplicates are disallowed
	if not include_duplicates and selected_options.size() > available_options.size():
		selected_options = selected_options.slice(0, available_options.size())

	_setup_ui()
	call_deferred(&"_refresh")


## Creates and adds the fold button and dropdown_container layout.
## The fold button toggles visibility of the dropdown list of option buttons.
func _setup_ui() -> void:
	fold_button = Button.new()
	fold_button.clip_text = true
	fold_button.toggle_mode = true
	fold_button.set_pressed_no_signal(is_expanded)
	fold_button.toggled.connect(_on_fold_button_toggled)
	_update_fold_button_text()

	add_child(fold_button)

	dropdown_container = PanelContainer.new()
	dropdown_container.add_theme_stylebox_override(
		&"panel",
		EditorInterface.get_editor_theme().get_stylebox(&"sub_inspector_bg1", &"EditorStyles"),
	)
	dropdown_container.add_child(VBoxContainer.new())
	dropdown_container.visible = is_expanded
	add_child(dropdown_container)


## Called when the fold toggle is pressed to show/hide tag rows.
## Updates the visibility of the dropdown container and button label.
func _on_fold_button_toggled(pressed: bool) -> void:
	is_expanded = pressed
	dropdown_container.visible = pressed
	set_bottom_editor(dropdown_container if is_expanded else null)
	_update_fold_button_text()


## Updates the fold button text to include current selected item count.
## Example: "StringList (3)"
func _update_fold_button_text() -> void:
	fold_button.text = "Array[%s] (size %d)" % [type_string(element_type), selected_options.size()]


## Rebuilds all rows and updates Add button.
## Called during initialization or when values change.
func _refresh() -> void:
	if _refreshing:
		return
	_refreshing = true

	var vbox: VBoxContainer = dropdown_container.get_child(0)
	for child in vbox.get_children():
		vbox.remove_child(child)
		child.queue_free()

	for i in range(selected_options.size()):
		_build_row(i)

	var add_button: Button = Button.new()
	add_button.icon = get_theme_icon(&"Add", &"EditorIcons")
	add_button.text = "Add Element"
	add_button.add_theme_constant_override("h_separation", get_theme_constant(&"h_separation", &"InspectorActionButton"))
	add_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	add_button.disabled = _get_unused_options().is_empty()
	add_button.pressed.connect(_on_add_pressed)
	vbox.add_child(add_button)

	call_deferred(&"_update_property")
	_update_fold_button_text()
	_refreshing = false


## Builds a single option_button row at the specified index.
## Each row includes a option_button for item selection and a remove button.
func _build_row(index: int) -> void:
	var vbox: VBoxContainer = dropdown_container.get_child(0)
	var row: HBoxContainer = HBoxContainer.new()

	var idx_label := Label.new()
	idx_label.text = str(index)
	idx_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(idx_label)

	var option_button: OptionButton = OptionButton.new()
	option_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	option_button.fit_to_longest_item = false
	option_button.clip_text = true
	var stylebox := EditorInterface.get_editor_theme().get_stylebox(&"child_bg", &"EditorProperty")
	option_button.add_theme_stylebox_override(&"normal", stylebox)
	option_button.add_theme_stylebox_override(&"hover", stylebox)
	option_button.add_theme_stylebox_override(&"pressed", stylebox)
	option_button.add_theme_stylebox_override(&"focus", stylebox)

	var used: Array[String] = selected_options.duplicate()
	used.remove_at(index)

	for option in available_options:
		var idx: int = option_button.item_count
		option_button.add_item(option)
		if not include_duplicates and used.has(option):
			option_button.set_item_disabled(idx, true)

	var current_index: int = available_options.find(selected_options[index])
	if current_index >= 0:
		option_button.select(current_index)

	option_button.item_selected.connect(
		func(i: int) -> void:
			var selected_value: String = available_options[i]
			if not include_duplicates and selected_value in selected_options and selected_options[index] != selected_value:
				option_button.select(available_options.find(selected_options[index]))
				return
			selected_options[index] = selected_value
			_emit_changed()
			call_deferred(&"_refresh")
	)

	var remove: Button = Button.new()
	remove.icon = get_theme_icon(&"Remove", &"EditorIcons")
	remove.tooltip_text = "Remove Element"
	remove.focus_mode = Control.FOCUS_NONE
	remove.pressed.connect(
		func() -> void:
			selected_options.remove_at(index)
			_emit_changed()
			call_deferred(&"_refresh")
	)

	row.add_child(option_button)
	row.add_child(remove)
	vbox.add_child(row)


## Emits the updated list of selected options to the inspector.
## Used to serialize the current dropdown values to the target resource.
func _emit_changed() -> void:
	if element_type == TYPE_STRING_NAME:
		var type_converted: Array[StringName] = []
		type_converted.assign(selected_options)
		emit_changed(get_edited_property(), type_converted)
	else:
		emit_changed(get_edited_property(), selected_options.duplicate())


## Adds the first unused option to the list and refreshes the editor.
## Called when the Add button is pressed.
func _on_add_pressed() -> void:
	var unused: Array[String] = _get_unused_options()
	if not unused.is_empty():
		selected_options.append(unused[0])
		_emit_changed()
		call_deferred(&"_refresh")


## Returns a list of options that have not yet been selected.
## Used to prevent duplicates and disable Add button when all are used.
func _get_unused_options() -> Array[String]:
	if include_duplicates:
		return available_options

	var result: Array[String] = []
	for item in available_options:
		if not selected_options.has(item):
			result.append(item)
	return result


## Called when external values change or the editor is reloaded.
## Ensures the selected options match the underlying array property.
func _update_property() -> void:
	var raw: Variant = get_edited_object().get(get_edited_property())
	if raw == null or not raw is Array[StringName] or raw is Array[String]:
		return

	var as_strings: Array[String]
	as_strings.assign(raw)

	var sanitized: Array[String] = _sanitize_options(as_strings)
	if selected_options != sanitized:
		selected_options = sanitized
		call_deferred(&"_refresh")


## Removes invalid or duplicate entries from the selected options list.
## Ensures only valid values remain and enforces uniqueness if duplicates are not allowed.
func _sanitize_options(options: Array[String]) -> Array[String]:
	var result: Array[String] = []
	var seen := { }

	for item in options:
		if not available_options.has(item):
			continue
		if not include_duplicates:
			if seen.has(item):
				continue
			seen[item] = true
		result.append(item)

	return result
