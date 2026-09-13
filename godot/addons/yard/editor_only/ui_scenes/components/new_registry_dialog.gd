@tool
extends ConfirmationDialog

# Used both for the 'New Registry' menu item
# and for the 'Registry Settings' button

signal settings_saved

enum RegistryDialogState { NEW_REGISTRY, REGISTRY_SETTINGS }
enum FileDialogState { CLASS_RESTRICTION, SCAN_DIRECTORY, REGISTRY_PATH }

const Namespace := preload("res://addons/yard/editor_only/namespace.gd")
const SCAN_RULESET_EDITOR := preload("./scan_ruleset_editor/scan_ruleset_editor.tscn")
const ScanRulesetEditor := preload("./scan_ruleset_editor/scan_ruleset_editor.gd")
const RegistryIO := Namespace.RegistryIO
const ClassUtils := Namespace.ClassUtils
const AnyIcon := Namespace.AnyIcon
const DEFAULT_COLOR = Color(0.71, 0.722, 0.745, 1.0)
const SUCCESS_COLOR = Color(0.45, 0.95, 0.5)
const WARNING_COLOR = Color(0.83, 0.78, 0.62)
const ERROR_COLOR = Color(1, 0.47, 0.42)

const ADVANCED_REGISTRY_PROPERTIES: Array[StringName] = [
	&"auto_rescan",
	&"remove_unmatched",
]

# would be a constant if not for the `tr()`
# TODO: update some strings + translations to account for multiple defined classes/directories +
# translations for allowed file extensions
var INFO_MESSAGES: Dictionary[StringName, Array] = {
	# --- Class restriction ---
	&"class_valid": [tr("Class/script is a Resource subclass."), SUCCESS_COLOR],
	&"class_invalid": [tr("Invalid class/script. Expected a Resource subclass (built-in, class_name, or [u]quoted[/u] script path)."), ERROR_COLOR],
	&"class_empty": [tr("No class filter, all Resource files will be accepted to the registry."), WARNING_COLOR],

	# --- Scan directory ---
	&"scan_valid": [tr("Scan directory valid. Will watch for new Resources…"), SUCCESS_COLOR],
	&"scan_root_warning": [tr("Scan directory is set to the project root ([code]res://[/code]). This will scan the entire project on every file save, which may cause significant editor lag."), WARNING_COLOR],
	&"scan_invalid": [tr("Scan directory invalid. Pick an existing directory."), ERROR_COLOR],
	&"scan_empty": [tr("No scan directory, resources auto-discovery is disabled."), DEFAULT_COLOR],

	# --- Allowed file extensions ---
	&"file_extensions_none": [tr("File extension restrictions are optional. Separate multiple extensions with commas."), DEFAULT_COLOR],
	&"file_extensions_valid": [tr("File extension filter active. Scan will be limited to matching extensions."), SUCCESS_COLOR],
	&"file_extensions_empty_extension": [tr("Empty file extension detected. Remove extra commas."), ERROR_COLOR],
	&"file_extensions_invalid_character": [tr("Invalid file extension detected. Remove disallowed characters."), ERROR_COLOR],

	# --- Scan regex ---
	&"regex_include_valid": [tr("Include filter active. Only matching paths will be scanned."), SUCCESS_COLOR],
	&"regex_include_invalid": [tr("Invalid include regex pattern."), ERROR_COLOR],
	&"regex_exclude_valid": [tr("Exclude filter active. Matching paths will be skipped."), SUCCESS_COLOR],
	&"regex_exclude_invalid": [tr("Invalid exclude regex pattern."), ERROR_COLOR],

	# --- Indexed properties ---
	&"properties_none": [tr("Indexed properties are optional. Separate multiple properties with commas."), DEFAULT_COLOR],
	&"properties_valid": [tr("All properties found on the specified resource class."), SUCCESS_COLOR],
	&"properties_empty_prop": [tr("Empty property name detected. Remove extra commas."), ERROR_COLOR],
	&"properties_class_type_mismatch": [tr("Property '{prop}' is declared on multiple classes with different types."), WARNING_COLOR],
	&"properties_cant_verify": [tr("Property '{prop}' may not exist on class {class_n}."), WARNING_COLOR],

	# --- Registry path ---
	&"path_available": [tr("Will create a new registry file."), SUCCESS_COLOR],
	&"path_invalid": [tr("Filename is invalid."), ERROR_COLOR],
	&"extension_invalid": [tr("Invalid extension."), ERROR_COLOR],
	&"filename_empty": [tr("Filename is empty."), ERROR_COLOR],
	&"path_already_used": [tr("Registry file already exists."), ERROR_COLOR],
}

var edited_registry: Registry

var _state: RegistryDialogState
var _file_dialog: EditorFileDialog
var _file_dialog_state: FileDialogState
var _add_ruleset_tab: ReferenceRect

@onready var global_settings_container: PanelContainer = %GlobalSettingsContainer
@onready var new_restriction_confirmation_dialog: ConfirmationDialog = %NewRestrictionConfirmationDialog
@onready var indexed_properties_line_edit: LineEdit = %IndexedPropertiesLineEdit
@onready var auto_rescan_label: Label = %AutoRescanLabel
@onready var auto_rescan_check_box: CheckBox = %AutoRescanCheckBox
@onready var scan_remove_unlisted_label: Label = %ScanRemoveUnlistedLabel
@onready var scan_remove_unlisted_check_box: CheckBox = %ScanRemoveUnlistedCheckBox
@onready var default_ruleset_editor: ScanRulesetEditor = %DefaultRulesetEditor
@onready var scan_rulesets_tab_container: TabContainer = %ScanRulesetsTabContainer
@onready var registry_path_line_edit: LineEdit = %RegistryPathLineEdit
@onready var registry_path_filesystem_button: Button = %RegistryPathFilesystemButton
@onready var advanced_settings_check_button: CheckButton = %AdvancedSettingsCheckButton
@onready var info_label: RichTextLabel = %InfoLabel

@onready var advanced_registry_properties_to_controls: Dictionary[StringName, Array] = {
	&"auto_rescan": [auto_rescan_label, auto_rescan_check_box],
	&"remove_unmatched": [scan_remove_unlisted_label, scan_remove_unlisted_check_box],
}

var _additional_scan_ruleset_editors_list: Array[ScanRulesetEditor] = []

var _last_file_dialog_requested_ruleset_editor: ScanRulesetEditor
var _all_ruleset_editors: Array[ScanRulesetEditor]:
	get:
		var all_editors: Array[ScanRulesetEditor] = [default_ruleset_editor]
		all_editors.append_array(_additional_scan_ruleset_editors_list)
		return all_editors


func _ready() -> void:
	if not Engine.is_editor_hint() or EditorInterface.get_edited_scene_root() == self:
		return

	add_theme_stylebox_override(&"panel", get_theme_stylebox(&"panel", &"EditorSettingsDialog"))
	global_settings_container.add_theme_stylebox_override(&"panel", get_theme_stylebox(&"BottomPanel", &"EditorStyles"))
	for check_box: CheckBox in [auto_rescan_check_box, scan_remove_unlisted_check_box]:
		check_box.add_theme_stylebox_override(&"focus", get_theme_stylebox(&"focus", &"LineEdit"))
		for override: StringName in [&"normal", &"hover", &"pressed", &"hover_pressed"]:
			check_box.add_theme_stylebox_override(override, get_theme_stylebox(&"normal", &"LineEdit"))

	about_to_popup.connect(_on_about_to_popup)
	_file_dialog = EditorFileDialog.new()
	_file_dialog.file_selected.connect(_on_file_dialog_file_selected)
	_file_dialog.dir_selected.connect(_on_file_dialog_dir_selected)
	add_child(_file_dialog)

	var rulesets_tab_bar := scan_rulesets_tab_container.get_tab_bar()
	rulesets_tab_bar.set_tab_title(0, "Default Ruleset")
	rulesets_tab_bar.tab_close_pressed.connect(_on_rulesets_tab_bar_close_pressed)
	_connect_ruleset_editor(default_ruleset_editor)

	_add_ruleset_tab = ReferenceRect.new()
	scan_rulesets_tab_container.add_child(_add_ruleset_tab)
	scan_rulesets_tab_container.set_tab_icon(_add_ruleset_tab.get_index(), get_theme_icon(&"Add", &"EditorIcons"))
	scan_rulesets_tab_container.set_tab_title(_add_ruleset_tab.get_index(), "")

	hide()


func popup_with_state(state: RegistryDialogState, dir: String = "") -> void:
	for existing_additional_ruleset_editor in _additional_scan_ruleset_editors_list:
		scan_rulesets_tab_container.remove_child(existing_additional_ruleset_editor)
		existing_additional_ruleset_editor.queue_free()
	_additional_scan_ruleset_editors_list.clear()

	var any_existing_advanced_settings := false

	_state = state
	if state == RegistryDialogState.NEW_REGISTRY:
		var default_settings := RegistryIO.RegistrySettings.new() # to use default values
		auto_rescan_check_box.button_pressed = default_settings.auto_rescan
		scan_remove_unlisted_check_box.button_pressed = default_settings.remove_unmatched
		indexed_properties_line_edit.text = default_settings.indexed_props
		title = "Create Registry"
		ok_button_text = "Create"
		registry_path_line_edit.editable = true
		registry_path_line_edit.focus_mode = Control.FOCUS_ALL
		registry_path_line_edit.text = dir.path_join("new_registry.tres")
		registry_path_filesystem_button.icon = AnyIcon.get_icon(&"Folder")
		registry_path_filesystem_button.tooltip_text = ""

		default_ruleset_editor.reset_properties(default_settings.default_scan_ruleset)

	elif edited_registry and state == RegistryDialogState.REGISTRY_SETTINGS:
		var settings := RegistryIO.get_registry_settings(edited_registry)
		indexed_properties_line_edit.text = settings.indexed_props
		auto_rescan_check_box.button_pressed = settings.auto_rescan
		scan_remove_unlisted_check_box.button_pressed = settings.remove_unmatched
		default_ruleset_editor.reset_properties(settings.default_scan_ruleset)
		for additional_ruleset in settings.additional_scan_rulesets:
			_add_additional_ruleset_editor(additional_ruleset)

		registry_path_line_edit.text = edited_registry.resource_path
		title = tr("Registry Settings", "RegistrySettingsDialog")
		ok_button_text = "Save"
		registry_path_line_edit.editable = false
		registry_path_line_edit.focus_mode = Control.FOCUS_NONE
		registry_path_filesystem_button.icon = AnyIcon.get_icon(&"ShowInFileSystem")
		registry_path_filesystem_button.tooltip_text = "Show in FileSystem"

		# Determine whether to show advanced settings
		var default_settings := RegistryIO.RegistrySettings.new()
		for advanced_registry_property in ADVANCED_REGISTRY_PROPERTIES:
			if settings[advanced_registry_property] != default_settings[advanced_registry_property]:
				any_existing_advanced_settings = true
				break

		if not any_existing_advanced_settings:
			any_existing_advanced_settings = ScanRulesetEditor.are_any_advanced_ruleset_settings_set(settings.default_scan_ruleset, default_settings.default_scan_ruleset)

		if not any_existing_advanced_settings:
			for additional_ruleset in settings.additional_scan_rulesets:
				any_existing_advanced_settings = ScanRulesetEditor.are_any_advanced_ruleset_settings_set(additional_ruleset, default_settings.default_scan_ruleset)
				if any_existing_advanced_settings:
					break

	else:
		return

	advanced_settings_check_button.button_pressed = any_existing_advanced_settings
	_on_scan_ruleset_additional_editors_list_updated()

	popup()


func _build_settings() -> RegistryIO.RegistrySettings:
	var settings := RegistryIO.RegistrySettings.new()
	settings.indexed_props = indexed_properties_line_edit.text.strip_edges()
	settings.auto_rescan = auto_rescan_check_box.button_pressed
	settings.remove_unmatched = scan_remove_unlisted_check_box.button_pressed
	settings.default_scan_ruleset = default_ruleset_editor._build_ruleset()
	for additional_ruleset_editor in _additional_scan_ruleset_editors_list:
		settings.additional_scan_rulesets.append(additional_ruleset_editor._build_ruleset())
	return settings


func _validate_fields() -> void:
	get_ok_button().disabled = false
	var info_messages: Array[Array] = [] # elements from INFO_MESSAGES

	# Collate ruleset validation state & messages; for every ruleset validation step, store a tuple
	# representing the most severe validation state result (Error -> Warning -> Success), and a
	# dictionary, with the unique message keys for that state as keys, and the count of editors that
	# returned that key as values.
	var ruleset_validation_resource_class_state: Array
	var ruleset_validation_scan_dir_state: Array
	var ruleset_validation_regex_include_state: Array
	var ruleset_validation_regex_exclude_state: Array
	var all_ruleset_validation_step_states := [
		ruleset_validation_resource_class_state,
		ruleset_validation_scan_dir_state,
		ruleset_validation_regex_include_state,
		ruleset_validation_regex_exclude_state,
	]

	for ruleset_editor in _all_ruleset_editors:
		var ruleset_validation_results := ruleset_editor._validate_fields()
		for i in all_ruleset_validation_step_states.size():
			var ruleset_validation_step_state: Array = all_ruleset_validation_step_states[i]
			var step_validation_results := ruleset_validation_results[i]
			var step_validation_state: ScanRulesetEditor.ValidationSubState = step_validation_results[0]
			var step_message_key: StringName = step_validation_results[1]

			if ruleset_validation_step_state.is_empty(): # The first results for this validation step
				ruleset_validation_step_state.append(step_validation_state)
				var new_message_keys_dict: Dictionary[StringName, int] = { }
				new_message_keys_dict[step_message_key] = 1
				ruleset_validation_step_state.append(new_message_keys_dict)
				continue

			var previous_validation_state: ScanRulesetEditor.ValidationSubState = ruleset_validation_step_state[0]
			var previous_validation_message_keys: Dictionary[StringName, int] = ruleset_validation_step_state[1]
			if step_validation_state == previous_validation_state: # Same state severity, so add this message + increment its count
				previous_validation_message_keys[step_message_key] = previous_validation_message_keys.get(step_message_key, 0) + 1
			elif step_validation_state > previous_validation_state: # More severe (e.g. Error > Warning)
				ruleset_validation_step_state[0] = step_validation_state
				previous_validation_message_keys.clear()
				previous_validation_message_keys[step_message_key] = 1

	# Show the corresponding (most severe) info messages for each ruleset validation step
	for ruleset_validation_step_state: Array in all_ruleset_validation_step_states:
		var step_validation_state: ScanRulesetEditor.ValidationSubState = ruleset_validation_step_state[0]
		var step_message_keys: Dictionary[StringName, int] = ruleset_validation_step_state[1]

		for message_key in step_message_keys:
			if message_key.is_empty():
				continue

			var editors_that_returned_key_count := step_message_keys[message_key]
			var new_info_message := INFO_MESSAGES[message_key]

			if editors_that_returned_key_count > 0:
				new_info_message = new_info_message.duplicate()
				new_info_message.append(editors_that_returned_key_count)

			if step_validation_state == ScanRulesetEditor.ValidationSubState.ERROR:
				_invalidate_with_full_info_message(info_messages, new_info_message)
			else:
				info_messages.append(new_info_message)

	# Indexed properties
	var indexed_props: Array[String] = []
	var indexed_properties_string := indexed_properties_line_edit.text.strip_edges()
	if indexed_properties_string.is_empty():
		info_messages.append(INFO_MESSAGES.properties_none)
	else:
		indexed_props.assign(indexed_properties_string.split(",", true))
		indexed_props.assign(indexed_props.map(func(s: String) -> String: return s.strip_edges()))
		if indexed_props.any(func(s: String) -> bool: return s.is_empty()):
			_invalidate(info_messages, &"properties_empty_prop")
		else:
			# For every mismatched property, track its name, and an array of the different expected
			# values that it has.
			# TODO: Actually implement & test this mismatched types check!
			var props_per_class: Dictionary[StringName, Array] = { }
			#var mismatched_property_types: Dictionary[String, Array] = { }

			for ruleset_editor in _all_ruleset_editors:
				var ruleset_unique_class_strings := ruleset_editor.get_unique_class_strings()
				for class_string in ruleset_unique_class_strings:
					if not props_per_class.has(class_string):
						props_per_class[class_string] = _get_class_property_names(class_string)

			for prop: String in indexed_props:
				var classes_without_prop := []
				for class_n in props_per_class:
					if not prop in props_per_class[class_n]:
						classes_without_prop.append(class_n)
				if not classes_without_prop.is_empty():
					var msg := INFO_MESSAGES.properties_cant_verify.duplicate()
					msg[0] = tr(msg[0]).format({ "prop": prop, "class_n": ", ".join(classes_without_prop) })
					info_messages.append(msg)

	if _state == RegistryDialogState.REGISTRY_SETTINGS:
		_fill_info_label(info_messages)
		return

	# Registry file path
	var file_path := registry_path_line_edit.text.strip_edges()
	if file_path.is_empty():
		_invalidate(info_messages, &"filename_empty")
	elif file_path.get_extension().to_lower() not in RegistryIO.REGISTRY_FILE_EXTENSIONS:
		_invalidate(info_messages, &"extension_invalid")
	elif not RegistryIO.is_valid_registry_output_path(file_path):
		_invalidate(info_messages, &"path_invalid")
	elif ResourceLoader.exists(file_path):
		_invalidate(info_messages, &"path_already_used")
	else:
		info_messages.append(INFO_MESSAGES.path_available)

	_fill_info_label(info_messages)


func _invalidate(info_messages: Array[Array], key: StringName) -> void:
	_invalidate_with_full_info_message(info_messages, INFO_MESSAGES[key])


# TODO: consider cleaned up approach w/_invalidate above. This updated approach lets us modify the
# info message before invalidation in case additional details are needed.
func _invalidate_with_full_info_message(info_messages: Array[Array], new_info_message: Array) -> void:
	get_ok_button().disabled = true
	info_messages.append(new_info_message)


func _get_class_property_names(class_string: String) -> Array[String]:
	if RegistryIO.is_quoted_string(class_string):
		return ClassUtils.get_class_property_names(load(RegistryIO.unquote(class_string)))
	return ClassUtils.get_class_property_names(class_string)


func _fill_info_label(info_messages: Array[Array]) -> void:
	info_label.text = ""

	var show_ruleset_editors_count := not _additional_scan_ruleset_editors_list.is_empty()

	for i in info_messages.size():
		if i != 0:
			info_label.newline()
			info_label.newline()
		var message: Array = info_messages[i]
		var text: String = message[0]
		var color: Color = message[1]
		var applicable_ruleset_editors_count: int = message[2] if show_ruleset_editors_count and message.size() >= 3 else -1

		info_label.push_color(color)
		info_label.append_text("• " + tr(text))
		if applicable_ruleset_editors_count > 0:
			info_label.append_text(" ×%d" % applicable_ruleset_editors_count)
		info_label.pop()


func _open_file_dialog_as_class_restriction(restriction: String, ruleset_editor: ScanRulesetEditor) -> void:
	_last_file_dialog_requested_ruleset_editor = ruleset_editor

	_file_dialog.title = tr("Choose Custom Resource Script")
	_file_dialog.clear_filters()
	_file_dialog.add_filter("*.gd", "Scripts")
	_file_dialog_state = FileDialogState.CLASS_RESTRICTION
	_file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	if not restriction.is_empty() and RegistryIO.is_quoted_string(restriction):
		var path := RegistryIO.unquote(restriction)
		_file_dialog.current_dir = path.get_base_dir()
		_file_dialog.current_path = path.get_file()
	else:
		_file_dialog.current_dir = ""
		_file_dialog.current_path = ""
	_file_dialog.popup_file_dialog()


func _open_file_dialog_as_scan_directory(scan_dir: String, ruleset_editor: ScanRulesetEditor) -> void:
	_last_file_dialog_requested_ruleset_editor = ruleset_editor

	_file_dialog.title = tr("Choose Directory to Scan")
	_file_dialog_state = FileDialogState.SCAN_DIRECTORY
	_file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
	var dir_exist := DirAccess.dir_exists_absolute(scan_dir)
	_file_dialog.current_dir = scan_dir if dir_exist else scan_dir.get_base_dir()
	_file_dialog.clear_filters()
	_file_dialog.popup_file_dialog()


func _open_file_dialog_as_registry_path() -> void:
	_file_dialog.title = tr("Choose Registry Location")
	_file_dialog.clear_filters()
	_file_dialog.add_filter("*.tres, *.res")
	_file_dialog_state = FileDialogState.REGISTRY_PATH
	_file_dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
	_file_dialog.current_dir = registry_path_line_edit.text.get_base_dir()
	_file_dialog.current_path = registry_path_line_edit.text.get_file()
	_file_dialog.popup_file_dialog()


func _on_ruleset_editor_request_class_restriction_class_list_dialog(class_restriction: String, ruleset_editor: ScanRulesetEditor) -> void:
	exclusive = false
	EditorInterface.popup_create_dialog(
		_on_class_list_dialog_confirmed.bind(ruleset_editor),
		&"Resource",
		class_restriction,
		tr("Choose Class Restriction"),
	)


func _on_class_list_dialog_confirmed(type_name: String, ruleset_editor: ScanRulesetEditor) -> void:
	exclusive = true
	grab_focus()
	if not type_name:
		return

	if type_name.begins_with("res://") or type_name.begins_with("uid://"):
		type_name = '"%s"' % type_name

	ruleset_editor.update_selected_class_restriction(type_name)


func _edit_settings_and_rebuild_index(already_built_settings: RegistryIO.RegistrySettings = null) -> void:
	var built_settings := already_built_settings if already_built_settings != null else _build_settings()
	var err := RegistryIO.set_registry_settings(edited_registry, built_settings)
	if err != OK:
		print_debug(error_string(err))

	err = RegistryIO.rebuild_property_index(edited_registry)
	if err != OK:
		print_debug(error_string(err))
	settings_saved.emit()


func _on_about_to_popup() -> void:
	_validate_fields()


func _on_close_requested() -> void:
	hide()


func _on_canceled() -> void:
	hide()


func _on_confirmed() -> void:
	match _state:
		RegistryDialogState.NEW_REGISTRY:
			hide()
			var registry_path := registry_path_line_edit.text.strip_edges()
			var err := RegistryIO.create_registry_file(registry_path, _build_settings())
			if err != OK:
				print_debug(error_string(err))
				return
			var new_registry: Registry = load(registry_path)
			EditorInterface.edit_resource(new_registry)
			err = RegistryIO.rebuild_property_index(new_registry)
			if err != OK:
				print_debug(error_string(err))
		RegistryDialogState.REGISTRY_SETTINGS:
			# Do a check to see whether the updated scan settings may be more restrictive than the
			# old ones, and if so, warn the user & require a confirmation to continue.
			# Multiple class restrictions
			var new_settings := _build_settings()
			var old_settings := RegistryIO.get_registry_settings(edited_registry)
			var scan_rulesets_changed := false
			if new_settings.additional_scan_rulesets.size() != old_settings.additional_scan_rulesets.size():
				scan_rulesets_changed = true
			else:
				if not new_settings.default_scan_ruleset.matches_other_ruleset(old_settings.default_scan_ruleset):
					scan_rulesets_changed = true
				else:
					for i in new_settings.additional_scan_rulesets.size():
						var new_ruleset := new_settings.additional_scan_rulesets[i]
						var old_ruleset := old_settings.additional_scan_rulesets[i]
						if not new_ruleset.matches_other_ruleset(old_ruleset, new_settings.default_scan_ruleset, old_settings.default_scan_ruleset):
							scan_rulesets_changed = true
							break

			if scan_rulesets_changed and RegistryIO.would_erase_entries(edited_registry, new_settings):
				new_restriction_confirmation_dialog.popup()
			else:
				hide()
				_edit_settings_and_rebuild_index(new_settings)


func _on_indexed_properties_line_edit_text_changed(_new_text: String) -> void:
	_validate_fields()


func _on_registry_path_line_edit_text_changed(_new_text: String) -> void:
	_validate_fields()


func _on_registry_path_filesystem_button_pressed() -> void:
	match _state:
		RegistryDialogState.NEW_REGISTRY:
			_open_file_dialog_as_registry_path()
		RegistryDialogState.REGISTRY_SETTINGS:
			var fs := EditorInterface.get_file_system_dock()
			fs.navigate_to_path(registry_path_line_edit.text)


func _on_file_dialog_file_selected(file: String) -> void:
	if _file_dialog_state == FileDialogState.CLASS_RESTRICTION:
		if is_instance_valid(_last_file_dialog_requested_ruleset_editor):
			_last_file_dialog_requested_ruleset_editor.update_selected_class_restriction("\"%s\"" % file)
		_validate_fields()
	elif _file_dialog_state == FileDialogState.REGISTRY_PATH:
		registry_path_line_edit.text = file
		_validate_fields()


func _on_file_dialog_dir_selected(path: String) -> void:
	if _file_dialog_state == FileDialogState.SCAN_DIRECTORY:
		if is_instance_valid(_last_file_dialog_requested_ruleset_editor):
			_last_file_dialog_requested_ruleset_editor.update_selected_scan_directory(path)
		_validate_fields()


func _update_ruleset_tabs_bar() -> void:
	var ruleset_tab_bar := scan_rulesets_tab_container.get_tab_bar()
	var additional_ruleset_editors_count := _additional_scan_ruleset_editors_list.size()
	for i in additional_ruleset_editors_count:
		ruleset_tab_bar.set_tab_title(i + 1, tr("Ruleset %d") % (i + 2))

	scan_rulesets_tab_container.tabs_visible = advanced_settings_check_button.button_pressed or not _additional_scan_ruleset_editors_list.is_empty()

	scan_rulesets_tab_container.get_tab_bar().tab_close_display_policy = (
		TabBar.CLOSE_BUTTON_SHOW_NEVER
		if scan_rulesets_tab_container.get_current_tab_control() == default_ruleset_editor
		else TabBar.CLOSE_BUTTON_SHOW_ACTIVE_ONLY
	)


func _on_scan_ruleset_additional_editors_list_updated() -> void:
	_update_ruleset_tabs_bar()
	_validate_fields()


func _on_new_restriction_confirmation_dialog_confirmed() -> void:
	hide()
	_edit_settings_and_rebuild_index()

# TODO: determine if we should be resetting the window/info label size with the current
# implementation - if so, we may want to listen for hierarchical Control/CanvasItem events for this.
#func _on_foldable_container_folding_changed(is_folded: bool) -> void:
#if is_folded:
#info_label.reset_size()
#reset_size()


func _connect_ruleset_editor(ruleset_editor: ScanRulesetEditor) -> void:
	ruleset_editor.inputs_changed.connect(_validate_fields)
	ruleset_editor.request_class_restriction_class_list_dialog.connect(_on_ruleset_editor_request_class_restriction_class_list_dialog.bind(ruleset_editor))
	ruleset_editor.request_class_restriction_file_dialog.connect(_open_file_dialog_as_class_restriction.bind(ruleset_editor))
	ruleset_editor.request_scan_directory_file_dialog.connect(_open_file_dialog_as_scan_directory.bind(ruleset_editor))


func _add_additional_ruleset_editor(ruleset_settings: RegistryIO.RegistryScanRuleset = null) -> void:
	var additional_ruleset_editor: ScanRulesetEditor = SCAN_RULESET_EDITOR.instantiate()
	_additional_scan_ruleset_editors_list.append(additional_ruleset_editor)
	scan_rulesets_tab_container.add_child(additional_ruleset_editor)
	scan_rulesets_tab_container.move_child(additional_ruleset_editor, _additional_scan_ruleset_editors_list.size())

	additional_ruleset_editor.default_ruleset_editor = default_ruleset_editor
	additional_ruleset_editor.is_additional_ruleset = true
	additional_ruleset_editor.show_advanced_settings = advanced_settings_check_button.button_pressed

	if ruleset_settings != null:
		additional_ruleset_editor.reset_properties(ruleset_settings)

	_connect_ruleset_editor(additional_ruleset_editor)

	_on_scan_ruleset_additional_editors_list_updated()


func _on_advanced_settings_check_button_toggled(toggled_on: bool) -> void:
	for property in ADVANCED_REGISTRY_PROPERTIES:
		for control: Control in advanced_registry_properties_to_controls[property]:
			control.visible = toggled_on

	default_ruleset_editor.show_advanced_settings = toggled_on

	for additional_ruleset_editor in _additional_scan_ruleset_editors_list:
		additional_ruleset_editor.show_advanced_settings = toggled_on

	_update_ruleset_tabs_bar()


func _on_scan_rulesets_tab_container_tab_clicked(tab: int) -> void:
	if scan_rulesets_tab_container.get_tab_control(tab) is ReferenceRect:
		_add_additional_ruleset_editor()
		scan_rulesets_tab_container.current_tab = _additional_scan_ruleset_editors_list.size()
	_update_ruleset_tabs_bar()


func _on_scan_rulesets_tab_container_tab_selected(tab: int) -> void:
	if not is_node_ready():
		return
	if scan_rulesets_tab_container.get_tab_control(tab) is ReferenceRect:
		scan_rulesets_tab_container.current_tab = _additional_scan_ruleset_editors_list.size()
	_update_ruleset_tabs_bar()


func _on_rulesets_tab_bar_close_pressed(tab: int) -> void:
	var ruleset_editor: ScanRulesetEditor = scan_rulesets_tab_container.get_tab_control(tab)
	if not _additional_scan_ruleset_editors_list.has(ruleset_editor):
		return

	_additional_scan_ruleset_editors_list.erase(ruleset_editor)
	scan_rulesets_tab_container.remove_child(ruleset_editor)
	ruleset_editor.queue_free()

	_on_scan_ruleset_additional_editors_list_updated()
