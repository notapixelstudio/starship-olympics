@tool
extends PanelContainer

enum EditMenuAction {
	NONE = -1,
	DELETE_ENTRIES = 0,
	COPY_STRING_ID = 1,
	COPY_UID = 2,
	SHOW_IN_FILESYSTEM = 3,
	CUT_CELL_VALUE = 5,
	COPY_CELL_VALUE = 6,
	PASTE_TO_CELL = 7,
	SELECT_ALL = 9,
	INVERT_SELECTION = 10,
	UNSELECT = 11,
}

const Namespace := preload("res://addons/yard/editor_only/namespace.gd")
const RegistryIO := Namespace.RegistryIO
const ClassUtils := Namespace.ClassUtils
const EditorThemeUtils := Namespace.EditorThemeUtils
const DynamicTable := Namespace.DynamicTable
const RegistryCacheData := Namespace.YardEditorCache.RegistryCacheData

const ACCELERATORS_WIN: Dictionary = {
	EditMenuAction.DELETE_ENTRIES: KEY_MASK_CTRL | KEY_BACKSPACE,
	EditMenuAction.CUT_CELL_VALUE: KEY_MASK_CTRL | KEY_X,
	EditMenuAction.COPY_CELL_VALUE: KEY_MASK_CTRL | KEY_C,
	EditMenuAction.PASTE_TO_CELL: KEY_MASK_CTRL | KEY_V,
	EditMenuAction.SELECT_ALL: KEY_MASK_CTRL | KEY_A,
}

const ACCELERATORS_MAC: Dictionary = {
	EditMenuAction.DELETE_ENTRIES: KEY_MASK_META | KEY_BACKSPACE,
	EditMenuAction.CUT_CELL_VALUE: KEY_MASK_META | KEY_X,
	EditMenuAction.COPY_CELL_VALUE: KEY_MASK_META | KEY_C,
	EditMenuAction.PASTE_TO_CELL: KEY_MASK_META | KEY_V,
	EditMenuAction.SELECT_ALL: KEY_MASK_META | KEY_A,
}

const INVALID_UID := "uid://<invalid>"
const LOGGING_INFO_COLOR := "lightslategray"
const UID_COLUMN_CONFIG := ["uid", "UID", TYPE_STRING]
const STRINGID_COLUMN_CONFIG := ["string_id", "String ID", TYPE_STRING]
const NON_PROP_COLUMNS_COUNT := 2
const STRINGID_COLUMN := 0
const UID_COLUMN := 1

var current_cache_data: RegistryCacheData
var properties_column_info: Array[Dictionary]
var entries_data: Array[Array] # inner arrays are rows, their content is columns
var clipboard: Variant

var current_registry: Registry:
	set(new):
		var is_another := new != current_registry
		current_registry = new
		current_cache_data = RegistryCacheData.load_or_default(new) if new else null
		if current_cache_data:
			_setup_add_entry()
			if is_another:
				dynamic_table.ordering_data(STRINGID_COLUMN, true)
		update_view()

var toggle_button_forward := false:
	set(forward):
		var icon_name := &"Forward" if forward else &"Back"
		toggle_registry_panel_button.icon = get_theme_icon(icon_name, &"EditorIcons")

var id_columns_frozen := true:
	set(frozen):
		id_columns_frozen = frozen
		dynamic_table.n_frozen_columns = 2 if frozen else 0
		dynamic_table._update_scrollbars() # private but whatever

var _texture_rect_parent: Button
var _res_picker: EditorResourcePicker
var _uid_resource_to_inspect: String
var _subresource_to_inspect: Resource

@onready var dynamic_table: DynamicTable = %DynamicTable
@onready var toggle_registry_panel_button: Button = %ToggleRegistryPanelButton
@onready var add_entry_container: HBoxContainer = %AddEntryContainer
@onready var resource_picker_container: PanelContainer = %ResourcePickerContainer
@onready var entry_name_line_edit: LineEdit = %EntryNameLineEdit
@onready var add_entry_button: Button = %AddEntryButton
@onready var edit_context_menu: PopupMenu = %EditContextMenu
@onready var delete_entries_confirmation_dialog := %DeleteEntriesConfirmationDialog
@onready var drag_and_drop_info_panel: PanelContainer = %DragAndDropInfoPanel
@onready var focus_panel: PanelContainer = %FocusPanel


func _ready() -> void:
	if not Engine.is_editor_hint() or EditorInterface.get_edited_scene_root() == self:
		return

	EditorInterface.get_inspector().property_edited.connect(
		_on_inspector_property_edited,
	)

	dynamic_table.cell_selected.connect(_on_cell_selected)
	dynamic_table.cell_right_selected.connect(_on_cell_right_selected)
	dynamic_table.cell_edited.connect(_on_cell_edited)
	dynamic_table.header_clicked.connect(_on_header_clicked)
	dynamic_table.column_resized.connect(_on_column_resized)
	dynamic_table.multiple_rows_selected.connect(_on_multiple_rows_selected)
	entry_name_line_edit.text_submitted.connect(_on_new_entry_text_submitted)

	var accelerators := ACCELERATORS_MAC if OS.get_name() == "macOS" else ACCELERATORS_WIN
	for action: EditMenuAction in accelerators:
		if edit_context_menu.get_item_index(action) != -1:
			edit_context_menu.set_item_accelerator(edit_context_menu.get_item_index(action), accelerators.get(action))

	# Resource Picker Theming
	resource_picker_container.add_theme_stylebox_override(
		&"panel",
		get_theme_stylebox("normal", "LineEdit").duplicate(),
	)
	resource_picker_container.get_theme_stylebox(&"panel").content_margin_bottom = 0
	resource_picker_container.get_theme_stylebox(&"panel").content_margin_top = 0
	resource_picker_container.get_theme_stylebox(&"panel").content_margin_left = 0
	resource_picker_container.get_theme_stylebox(&"panel").content_margin_right = 0

	drag_and_drop_info_panel.get_theme_stylebox(&"panel").bg_color = EditorThemeUtils.get_base_color(
		0.6,
	)
	drag_and_drop_info_panel.get_theme_stylebox(&"panel").bg_color.a = 0.8
	focus_panel.add_theme_stylebox_override(&"panel", get_theme_stylebox("Focus", "EditorStyles"))

	if ClassUtils.is_engine_version_equal_or_newer(4, 6):
		var files_shortcut: Shortcut = EditorInterface.get_editor_settings().get_shortcut("script_editor/toggle_files_panel")
		if files_shortcut:
			toggle_registry_panel_button.shortcut = files_shortcut

	grow_horizontal = Control.GROW_DIRECTION_END
	grow_vertical = Control.GROW_DIRECTION_END
	id_columns_frozen = id_columns_frozen # to refresh


func _process(_delta: float) -> void:
	# Too many load() and inspect requests might be the source of the 'Abort trap: 6' crashes
	if (_uid_resource_to_inspect or _subresource_to_inspect) and Engine.get_process_frames() % 30 == 0:
		if _subresource_to_inspect:
			EditorInterface.edit_resource(_subresource_to_inspect)
			_subresource_to_inspect = null
		elif _uid_resource_to_inspect:
			EditorInterface.edit_resource(load(_uid_resource_to_inspect))
			_uid_resource_to_inspect = ""

	if _texture_rect_parent and _texture_rect_parent.custom_minimum_size != Vector2(1, 1):
		# It's set by C++ code to enlarge the resource preview in the inspector.
		# Since we want the bottom bar height to remain constant, we have to reset it.
		_texture_rect_parent.custom_minimum_size = Vector2(1, 1)

	if not get_viewport().gui_is_dragging():
		drag_and_drop_info_panel.visible = (
			current_registry and current_registry.is_empty()
		)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_DRAG_BEGIN:
			_on_drag_begin()
		NOTIFICATION_DRAG_END:
			_on_drag_end()


func _shortcut_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return

	if dynamic_table.has_focus() and edit_context_menu.activate_item_by_event(event):
		get_viewport().set_input_as_handled()


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if typeof(data) != TYPE_DICTIONARY or not data.has("files"):
		return false

	if not current_registry:
		return false

	var settings := RegistryIO.get_registry_settings(current_registry)
	var all_class_restrictions := settings.get_all_class_restrictions()
	var scan_rulesets := settings.get_compiled_rulesets()

	for path: String in data.files:
		if ResourceLoader.exists(path):
			if RegistryIO.does_resource_match_class_restrictions(load(path), all_class_restrictions):
				return true

		elif path.ends_with("/"): # is dir
			for scan_ruleset in scan_rulesets:
				if RegistryIO.dir_has_matching_resource(path, scan_ruleset, "", true):
					return true

	return false


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var n_added := 0

	var settings := RegistryIO.get_registry_settings(current_registry)
	var all_class_restrictions := settings.get_all_class_restrictions()
	var scan_rulesets := settings.get_compiled_rulesets()

	for path: String in data.files:
		if ResourceLoader.exists(path):
			if RegistryIO.does_resource_match_class_restrictions(load(path), all_class_restrictions):
				var status := RegistryIO.add_entry(current_registry, ResourceUID.path_to_uid(path))
				n_added += int(status == OK)

		elif path.ends_with("/"):
			for scan_ruleset in scan_rulesets:
				var matching_resources := RegistryIO.dir_get_matching_resources(path, scan_ruleset, "", true)
				for res in matching_resources:
					var status := RegistryIO.add_entry(
						current_registry,
						ResourceUID.path_to_uid(res.resource_path),
					)
					n_added += int(status == OK)

	print_rich("[color=%s]Added %s new Resources to the registry.[/color]" % [LOGGING_INFO_COLOR, n_added])
	update_view()


func update_view() -> void:
	if not current_registry:
		add_entry_container.visible = false
		dynamic_table.set_columns([])
		var empty_data: Array[Array] = [[]]
		dynamic_table.set_data(empty_data)
		return

	var table_state := [dynamic_table.focused_row, dynamic_table.focused_col, dynamic_table.selected_rows, dynamic_table._last_column_sorted, dynamic_table._ascending]
	var focus_owner := get_viewport().gui_get_focus_owner() if get_viewport() else null
	var table_had_focus := focus_owner and (dynamic_table == focus_owner or dynamic_table.is_ancestor_of(focus_owner))

	add_entry_container.visible = true

	var resources: Dictionary[StringName, Resource] = current_registry.load_all_blocking()
	set_columns_data(resources.values())
	entries_data.clear()
	for uid in current_registry.get_all_uids():
		var entry_data := [current_registry.get_string_id(uid), uid]
		if RegistryIO.is_uid_valid(uid):
			entry_data.append_array(get_res_row_data(current_registry.load_entry(uid)))
		else:
			entry_data[UID_COLUMN] = INVALID_UID
			entry_data.append_array(get_res_row_data(null))
		entries_data.append(entry_data)

	dynamic_table.set_columns(_build_columns())

	for idx in dynamic_table._columns.size():
		var column := dynamic_table.get_column(idx)
		match idx:
			UID_COLUMN:
				column.current_width = current_cache_data.uid_column_width
			STRINGID_COLUMN:
				column.current_width = current_cache_data.string_id_column_width
			_:
				var prop_name := column.identifier
				if current_cache_data.property_columns_widths.has(prop_name):
					column.current_width = current_cache_data.property_columns_widths[prop_name]

	dynamic_table.set_data(entries_data)

	dynamic_table.ordering_data(table_state[3], table_state[4])
	if table_had_focus:
		dynamic_table.grab_focus()
		dynamic_table.set_selected_cell(table_state[0], table_state[1])
		dynamic_table.selected_rows = table_state[2]


func do_edit_menu_action(action_id: int) -> void:
	if not current_registry:
		return
	match action_id:
		EditMenuAction.DELETE_ENTRIES:
			_ask_confirm_delete_entries()
		EditMenuAction.COPY_STRING_ID:
			DisplayServer.clipboard_set(get_row_resource_string_id(dynamic_table.focused_row))
		EditMenuAction.COPY_UID:
			DisplayServer.clipboard_set(get_row_resource_uid(dynamic_table.focused_row))
		EditMenuAction.SHOW_IN_FILESYSTEM:
			var uid := get_row_resource_uid(dynamic_table.focused_row)
			var path := ResourceUID.uid_to_path(uid)
			EditorInterface.get_file_system_dock().navigate_to_path(path)
		EditMenuAction.CUT_CELL_VALUE:
			var row := dynamic_table.focused_row
			var col := dynamic_table.focused_col
			var value: Variant = dynamic_table.get_cell_value(row, col)
			if not dynamic_table.is_cell_invalid(row, col):
				clipboard = value
				_on_cell_edited(row, col, value, null)
		EditMenuAction.COPY_CELL_VALUE:
			var row := dynamic_table.focused_row
			var col := dynamic_table.focused_col
			var value: Variant = dynamic_table.get_cell_value(row, col)
			if not dynamic_table.is_cell_invalid(row, col):
				clipboard = value
		EditMenuAction.PASTE_TO_CELL:
			var row := dynamic_table.focused_row
			var col := dynamic_table.focused_col
			var value: Variant = dynamic_table.get_cell_value(row, col)
			if not dynamic_table.is_cell_invalid(row, col):
				_on_cell_edited(row, col, value, clipboard)
		EditMenuAction.SELECT_ALL:
			_select_all()
		EditMenuAction.INVERT_SELECTION:
			_invert_selection()
		EditMenuAction.UNSELECT:
			_unselect()


func is_property_disabled(property_info: Dictionary) -> bool:
	return property_info[&"name"] in current_cache_data.disabled_columns


func set_columns_data(resources: Array[Resource]) -> void:
	properties_column_info.clear()
	var found_props := _collect_props(resources)
	var grouped := _group_props_by_class(found_props)

	var ordered_groups: Array[String] = ClassUtils.sort_by_inheritance(grouped.keys())
	if not current_cache_data.parent_props_first:
		ordered_groups.reverse()

	for class_str: String in ordered_groups:
		for prop_name: StringName in grouped[class_str]:
			var prop := found_props[prop_name]
			if _can_display_property(prop) or ClassUtils.is_class_property(prop):
				properties_column_info.append(prop)


func get_res_row_data(res: Resource) -> Array[Variant]:
	if properties_column_info.is_empty() or not res:
		return []

	var row: Array[Variant] = []
	for prop: Dictionary in properties_column_info:
		if is_property_disabled(prop) or ClassUtils.is_class_property(prop):
			continue
		if prop[&"name"] in res:
			row.append(res.get(prop[&"name"]))
		else:
			row.append(DynamicTable.CELL_INVALID)
	return row


func get_row_resource_uid(row: int) -> StringName:
	var string_id: Variant = dynamic_table.get_cell_value(row, STRINGID_COLUMN)
	if string_id and string_id is StringName:
		return current_registry.get_uid(string_id)
	else:
		return &""


func get_row_resource_string_id(row: int) -> StringName:
	var string_id: StringName = dynamic_table.get_cell_value(row, STRINGID_COLUMN)
	return string_id


func toggle_edit_menu_items(edit_menu: PopupMenu) -> void:
	var row := dynamic_table.focused_row
	var col := dynamic_table.focused_col
	var has_selected_cell := -1 not in [row, col]
	var has_selected_row: = row != -1
	var cell_value: Variant = dynamic_table.get_cell_value(row, col) if has_selected_cell else null
	var cant_be_cut := col in [UID_COLUMN, STRINGID_COLUMN]
	var is_cell_invalid: bool = cell_value is String and cell_value == dynamic_table.CELL_INVALID
	edit_menu.set_item_disabled(edit_menu.get_item_index(EditMenuAction.DELETE_ENTRIES), !has_selected_row)
	edit_menu.set_item_disabled(edit_menu.get_item_index(EditMenuAction.COPY_STRING_ID), !has_selected_row)
	edit_menu.set_item_disabled(edit_menu.get_item_index(EditMenuAction.COPY_UID), !has_selected_row)
	edit_menu.set_item_disabled(edit_menu.get_item_index(EditMenuAction.SHOW_IN_FILESYSTEM), !has_selected_row)
	edit_menu.set_item_disabled(edit_menu.get_item_index(EditMenuAction.CUT_CELL_VALUE), !has_selected_cell or cant_be_cut or is_cell_invalid)
	edit_menu.set_item_disabled(edit_menu.get_item_index(EditMenuAction.COPY_CELL_VALUE), !has_selected_cell or is_cell_invalid)
	edit_menu.set_item_disabled(edit_menu.get_item_index(EditMenuAction.PASTE_TO_CELL), !has_selected_cell or is_cell_invalid)

	for select_action: int in [EditMenuAction.SELECT_ALL, EditMenuAction.INVERT_SELECTION, EditMenuAction.UNSELECT]:
		edit_menu.set_item_disabled(edit_menu.get_item_index(select_action), false)

	if dynamic_table.selected_rows.size() > 1:
		edit_menu.set_item_text(
			edit_menu.get_item_index(EditMenuAction.DELETE_ENTRIES),
			"Delete Entries (%s)" % dynamic_table.selected_rows.size(),
		)
	else:
		edit_menu.set_item_text(edit_menu.get_item_index(EditMenuAction.DELETE_ENTRIES), "Delete Entry")


func _build_columns() -> Array[DynamicTable.ColumnConfig]:
	var columns: Array[DynamicTable.ColumnConfig] = []

	var string_id_column: DynamicTable.ColumnConfig = DynamicTable.ColumnConfig.new.callv(STRINGID_COLUMN_CONFIG)
	string_id_column.custom_font_color = get_theme_color(&"accent_color", &"Editor")
	string_id_column.h_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	columns.append(string_id_column) #0

	var uid_column: DynamicTable.ColumnConfig = DynamicTable.ColumnConfig.new.callv(UID_COLUMN_CONFIG)
	uid_column.custom_font_color = get_theme_color(&"disabled_font_color", &"Editor")
	uid_column.property_hint = PROPERTY_HINT_FILE
	columns.append(uid_column) #1

	for prop in properties_column_info:
		if not _can_display_property(prop) or is_property_disabled(prop):
			continue

		var prop_name: String = prop[&"name"]
		var prop_header := prop_name.capitalize()
		var prop_type: Variant.Type = prop[&"type"]
		var hint: PropertyHint = prop[&"hint"]
		var hint_string: String = prop[&"hint_string"]
		var class_string: String = prop[&"class_name"]
		var column := DynamicTable.ColumnConfig.new(
			prop[&"name"],
			prop_header,
			prop_type,
		)

		if hint:
			column.property_hint = hint
		if hint_string:
			column.hint_string = hint_string
		if class_string:
			column.class_string = class_string

		columns.append(column)

	return columns


func _collect_props(resources: Array[Resource]) -> Dictionary[StringName, Dictionary]:
	var found_props: Dictionary[StringName, Dictionary] = { }
	for res: Resource in resources:
		if res:
			for prop: Dictionary in res.get_property_list():
				prop[&"owner_object"] = res
				found_props[prop[&"name"]] = prop
	return found_props


func _group_props_by_class(found_props: Dictionary) -> Dictionary[String, Array]:
	var grouped: Dictionary[String, Array] = { }
	var current_group: Array[String] = []
	var current_class: String

	for prop: Dictionary in found_props.values():
		if ClassUtils.is_class_property(prop):
			if current_group.size() > 0:
				grouped[current_class] = current_group
			current_group = [prop[&"name"]]
			current_class = ClassUtils.get_class_name_or_path_from_prop(prop)
		else:
			current_group.append(prop[&"name"])

	if current_group.size() > 0:
		grouped[current_class] = current_group

	return grouped


func _can_display_property(property_info: Dictionary) -> bool:
	return (
		property_info[&"type"] not in [TYPE_CALLABLE, TYPE_SIGNAL]
		and property_info[&"usage"] & PROPERTY_USAGE_EDITOR != 0
	)


func _edit_entry_property(entry: StringName, property: StringName, old_value: Variant, new_value: Variant) -> void:
	var uid := current_registry.get_uid(entry)
	if not uid or not RegistryIO.is_uid_valid(uid):
		return

	var res := load(entry)
	if not property in res:
		print_rich(
			"[color=%s]● [b]ERROR:[/b] Property %s not in resource[/color]" % [
				EditorThemeUtils.color_error.to_html(false),
				property,
			],
		)
		return

	var prop_types := ClassUtils.get_property_declared_types(res, property)
	if new_value == null:
		if res.get_script():
			new_value = res.get_script().get_property_default_value(property)
		else:
			new_value = ClassDB.class_get_property_default_value(ClassUtils.get_type_name(res), property)

	var valid := false
	for prop_type: String in prop_types:
		if (
			(ClassUtils.is_type_builtin(typeof(new_value)) and type_string(typeof(new_value)) == prop_type)
			or (typeof(new_value) in [TYPE_INT, TYPE_FLOAT] and prop_type in [type_string(TYPE_INT), type_string(TYPE_FLOAT)])
			or ClassUtils.is_class_of(new_value, prop_type)
			or (new_value == null and typeof(old_value) == TYPE_OBJECT)
		):
			valid = true
			break
		elif typeof(new_value) in [TYPE_INT, TYPE_FLOAT] and prop_type == type_string(TYPE_STRING):
			valid = true
			new_value = str(new_value)
			break

	if not valid:
		print_rich(
			"[color=%s]● [b]ERROR:[/b] Invalid type. Couldn't set %s (%s) to %s (%s)[/color]" % [
				EditorThemeUtils.color_error.to_html(false),
				property,
				", ".join(prop_types),
				new_value,
				ClassUtils.get_type_name(new_value),
			],
		)
		return

	res.set(property, new_value)
	var old_is_string := typeof(old_value) in [TYPE_STRING, TYPE_STRING_NAME]
	var new_is_string := typeof(res.get(property)) in [TYPE_STRING, TYPE_STRING_NAME]
	print_rich(
		"[color=%s]Set %s—>%s from %s to %s[/color]" % [
			LOGGING_INFO_COLOR,
			current_registry.get_string_id(uid),
			property,
			'"' + old_value + '"' if old_is_string else old_value,
			'"' + res.get(property) + '"' if new_is_string else res.get(property),
		],
	)


func _ask_confirm_delete_entries() -> void:
	var dialogtext := "Are you sure you want to delete %s?"
	if not dynamic_table.selected_rows.is_empty():
		delete_entries_confirmation_dialog.dialog_text = dialogtext % ["these " + str(dynamic_table.selected_rows.size()) + " entries"]
	else:
		delete_entries_confirmation_dialog.dialog_text = dialogtext % "this entry"
	delete_entries_confirmation_dialog.show()


func _setup_add_entry() -> void:
	if _res_picker:
		_res_picker.queue_free()
	_res_picker = EditorResourcePicker.new()
	_res_picker.custom_minimum_size = Vector2(240, 0)

	_res_picker.base_type = "Resource"
	var settings := RegistryIO.get_registry_settings(current_registry)

	if settings.has_any_class_restrictions():
		var all_class_restrictions_usable_strings: PackedStringArray
		for restriction in settings.get_all_class_restrictions():
			if not RegistryIO.is_quoted_string(restriction):
				all_class_restrictions_usable_strings.append(restriction)
			else:
				var script: Script = load(RegistryIO.unquote(restriction))
				all_class_restrictions_usable_strings.append(ClassUtils.get_type_name(script))
		if not all_class_restrictions_usable_strings.is_empty():
			_res_picker.base_type = ",".join(all_class_restrictions_usable_strings)

	resource_picker_container.add_child(_res_picker)
	_texture_rect_parent = _res_picker.get_child(0)
	_res_picker.resource_changed.connect(_on_res_picker_resource_changed)
	_res_picker.resource_selected.connect(_on_res_picker_resource_selected)
	_toggle_add_entry_button()
	entry_name_line_edit.text = ""


func _add_entry_from_picker(res: Resource, string_id: StringName) -> void:
	var res_is_file := res.resource_path and ResourceLoader.exists(res.resource_path)
	if not res_is_file:
		var current_dir := EditorInterface.get_current_path().get_base_dir()
		var save_path := current_dir.path_join(str(string_id) + ".tres")
		if ResourceLoader.exists(save_path):
			_print_fake_error("A file already exists at '%s'. Choose a different String ID or save the resource manually first." % save_path)
			return
		var save_status := ResourceSaver.save(res, save_path, ResourceSaver.FLAG_CHANGE_PATH)
		if save_status != OK:
			_print_fake_error("Failed to save resource to '%s'." % save_path)
			return
		EditorInterface.get_editor_toaster().push_toast("Resource saved to %s" % save_path)
		res = load(save_path) # Required because of race condition shinenigans I guess

	var uid := ResourceUID.path_to_uid(res.resource_path)

	var adding_status := RegistryIO.add_entry(current_registry, uid, string_id)
	match adding_status:
		OK:
			if res_is_file:
				_res_picker.edited_resource = null
			entry_name_line_edit.text = ""
			_toggle_add_entry_button()
			update_view()
		ERR_ALREADY_EXISTS:
			_print_fake_error("An entry with the same UID already exists in the registry.")
		ERR_CANT_ACQUIRE_RESOURCE:
			_print_fake_error("This resource is not saved as a file. Click [b]⌄[/b] then [b]Save[/b] on the resource picker to save it first.")
		ERR_INVALID_PARAMETER:
			_print_fake_error("The String ID is invalid. It must not start with 'uid://'.")
		ERR_DATABASE_CANT_WRITE:
			_print_fake_error("This resource doesn't match the registry class restriction.")
		_:
			_print_fake_error("Failed to add entry to the registry.")


func _toggle_add_entry_button() -> void:
	add_entry_button.disabled = !(
		_res_picker and _res_picker.edited_resource and entry_name_line_edit.text
	)


func _toggle_edit_context_menu_items() -> void:
	toggle_edit_menu_items(edit_context_menu)


func _delete_selected_entries() -> void:
	for row_idx: int in dynamic_table.selected_rows:
		var uid := get_row_resource_uid(row_idx)
		if RegistryIO.erase_entry(current_registry, uid) != OK:
			_print_fake_error(
				"Failed to remove %s from %s." % [uid, current_registry.resource_path.get_file()],
			)

	dynamic_table.set_selected_cell(-1, -1) # cancel current selection
	update_view()


func _select_all() -> void:
	dynamic_table.select_all_rows()
	dynamic_table.queue_redraw()


func _invert_selection() -> void:
	var selection := dynamic_table.selected_rows
	var inverted := []
	for row in dynamic_table._total_rows:
		if row not in selection:
			inverted.append(row)
	dynamic_table.selected_rows = inverted
	dynamic_table.queue_redraw()


func _unselect() -> void:
	dynamic_table.selected_rows = []
	dynamic_table.queue_redraw()


func _print_fake_error(message: String) -> void:
	print_rich(
		"[color=%s]● [b]ERROR:[/b] %s[/color]" % [
			EditorThemeUtils.color_error.to_html(false),
			message,
		],
	)


func _on_drag_begin() -> void:
	if not current_registry:
		drag_and_drop_info_panel.visible = false
		return
	var drag_data: Variant = get_viewport().gui_get_drag_data()
	var can_drop := drag_data != null and _can_drop_data(Vector2.ZERO, drag_data)
	drag_and_drop_info_panel.visible = can_drop or current_registry.is_empty()
	focus_panel.visible = can_drop


func _on_drag_end() -> void:
	drag_and_drop_info_panel.hide()
	focus_panel.hide()


func _on_cell_selected(row: int, column: int) -> void:
	# WARNING: uncommenting it increases the chance of a crash occuring by a lot. Inexplicable,
	# but supposedly related to switching selected cell with arrow keys. Only report: 'Abort trap: 6'
	#print("Cell selected on row ", row, ", column ", column, " Cell value: ", dynamic_table.get_cell_value(row, column)) #, " Row value: ", dynamic_table.get_row_value(row))
	if row != -1 and column != -1:
		var cell_value: Variant = dynamic_table.get_cell_value(row, column)
		if cell_value is Resource:
			_subresource_to_inspect = cell_value
			_uid_resource_to_inspect = ""
		else:
			_subresource_to_inspect = null
			var uid: StringName = get_row_resource_uid(row)
			if RegistryIO.is_uid_valid(uid):
				_uid_resource_to_inspect = uid


func _on_cell_right_selected(row: int, _column: int, _mouse_pos: Vector2) -> void:
	if (row >= 0): # ignore header cells
		edit_context_menu.popup(Rect2(DisplayServer.mouse_get_position(), Vector2.ZERO))


func _on_multiple_rows_selected(_rows: Array) -> void:
	#print("Multiple row selected : ", rows)
	pass


func _on_cell_edited(row: int, column: int, old_value: Variant, new_value: Variant) -> void:
	if column not in [UID_COLUMN, STRINGID_COLUMN]:
		var entry := get_row_resource_uid(row)
		var col_config: DynamicTable.ColumnConfig = dynamic_table.get_column(column)
		var prop_name: StringName = col_config.identifier
		if RegistryIO.is_uid_valid(entry):
			_edit_entry_property(entry, prop_name, old_value, new_value)
	elif column == STRINGID_COLUMN and new_value:
		RegistryIO.rename_entry(current_registry, old_value, new_value)
	elif column == UID_COLUMN and new_value:
		var old_uid := get_row_resource_uid(row) # Needed because the cell might store uid://<invalid>
		RegistryIO.change_entry_uid(current_registry, old_uid, new_value)
	update_view()


func _on_header_clicked(_column: int) -> void:
	#print("Header clicked on column ", column)
	pass


func _on_column_resized(column: int, new_width: float) -> void:
	match column:
		UID_COLUMN:
			current_cache_data.uid_column_width = new_width
		STRINGID_COLUMN:
			current_cache_data.string_id_column_width = new_width
		_:
			var col_config: DynamicTable.ColumnConfig = dynamic_table.get_column(column)
			var prop_name: StringName = col_config.identifier
			current_cache_data.property_columns_widths[prop_name] = new_width

	current_cache_data.save()


func _on_inspector_property_edited(_property: StringName) -> void:
	var object := EditorInterface.get_inspector().get_edited_object()
	if object is not Resource or not current_registry:
		return

	var res: Resource = object
	var uid := ResourceUID.path_to_uid(res.resource_path)
	if uid.begins_with("uid://") and current_registry.has_uid(uid):
		update_view()


func _on_edit_context_menu_id_pressed(id: int) -> void:
	do_edit_menu_action(id)


func _on_entry_name_line_edit_text_changed(_new_text: String) -> void:
	_toggle_add_entry_button()


func _on_res_picker_resource_changed(_new_resource: Resource) -> void:
	_toggle_add_entry_button()


func _on_res_picker_resource_selected(resource: Resource, inspect: bool) -> void:
	if inspect:
		EditorInterface.edit_resource(resource)


func _on_delete_entries_confirmation_dialog_confirmed() -> void:
	_delete_selected_entries()


func _on_edit_context_menu_about_to_popup() -> void:
	_toggle_edit_context_menu_items()


func _on_new_entry_text_submitted(_new_text: String) -> void:
	_on_add_entry_button_pressed()


func _on_add_entry_button_pressed() -> void:
	_toggle_add_entry_button()
	if add_entry_button.disabled:
		return

	_add_entry_from_picker(_res_picker.edited_resource, StringName(entry_name_line_edit.text))
