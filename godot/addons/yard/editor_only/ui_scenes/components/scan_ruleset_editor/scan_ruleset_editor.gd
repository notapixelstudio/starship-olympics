@tool
extends HBoxContainer

signal inputs_changed
signal request_class_restriction_class_list_dialog(class_restriction: String)
signal request_class_restriction_file_dialog(class_restriction: String)
signal request_scan_directory_file_dialog(scan_dir: String)

const Namespace := preload("../../../namespace.gd")
const OVERRIDE_DEFAULT_SETTING_TOGGLE_BUTTON := preload("./override_default_setting_toggle_button.tscn")
const NewRegistryDialog := preload("../new_registry_dialog.gd")
const ScanRulesetEditor := preload("./scan_ruleset_editor.gd")
const ScanInputsTabContainer := preload("./scan_tab_inputs/scan_inputs_tab_container.gd")
const ClassRestrictionInput := preload("./scan_tab_inputs/class_restriction_input.gd")
const ScanDirectoryInput := preload("./scan_tab_inputs/scan_directory_input.gd")
const RegistryIO := Namespace.RegistryIO
const AnyIcon := Namespace.AnyIcon

const ADVANCED_RULESET_PROPERTIES: Array[StringName] = [
	&"scan_regex_include",
	&"scan_regex_exclude",
]

const DEFAULT_OVERRIDDEN_RULESET_PROPERTIES: Array[StringName] = [
	&"scan_directories",
]

enum ValidationSubState { INFO, SUCCESS, WARNING, ERROR }

@onready var ruleset_properties_grid_container: GridContainer = %RulesetPropertiesGridContainer
@onready var class_restrictions_tab_container: TabContainer = %ClassRestrictionsTabContainer
@onready var scan_directories_tab_container: TabContainer = %ScanDirectoriesTabContainer
@onready var recursive_scan_label: Label = %RecursiveScanLabel
@onready var recursive_scan_check_box: CheckBox = %RecursiveScanCheckBox
@onready var allowed_file_extensions_label: Label = %AllowedFileExtensionsLabel
@onready var allowed_file_extensions_line_edit: LineEdit = %AllowedFileExtensionsLineEdit
@onready var scan_regex_include_label: Label = %ScanRegexIncludeLabel
@onready var scan_regex_include_line_edit: LineEdit = %ScanRegexIncludeLineEdit
@onready var scan_regex_exclude_label: Label = %ScanRegexExcludeLabel
@onready var scan_regex_exclude_line_edit: LineEdit = %ScanRegexExcludeLineEdit

## Map RegistryScanRuleset properties to the controls that their override buttons should be spawned
## before in the scene tree, for additional ruleset editors that need to allow those buttons.
@onready var scan_ruleset_properties_to_root_edit_controls: Dictionary[StringName, Control] = {
	&"class_restrictions": class_restrictions_tab_container,
	&"scan_directories": scan_directories_tab_container,
	&"recursive_scan": recursive_scan_check_box,
	&"allowed_file_extensions": allowed_file_extensions_line_edit,
	&"scan_regex_include": scan_regex_include_line_edit,
	&"scan_regex_exclude": scan_regex_exclude_line_edit,
}

@onready var advanced_ruleset_properties_to_controls: Dictionary[StringName, Array] = {
	&"scan_regex_include": [scan_regex_include_label, scan_regex_include_line_edit],
	&"scan_regex_exclude": [scan_regex_exclude_label, scan_regex_exclude_line_edit],
}

## Map RegistryScanRuleset properties to the names of all editor controls that should be reset and
## disabled when that property is using the default values. Property names are used instead of
## references, because we need to access those values on the default editor instance too.
## NOTE: although this is similar to the _to_root_edit_controls mapping above, it serves a different
## purpose and shouldn't be consolidated.
@onready var scan_ruleset_properties_to_all_control_properties: Dictionary[StringName, Array] = {
	&"class_restrictions": [&"class_restrictions_tab_container"],
	&"scan_directories": [&"scan_directories_tab_container"],
	&"recursive_scan": [&"recursive_scan_check_box"],
	&"allowed_file_extensions": [&"allowed_file_extensions_line_edit"],
	&"scan_regex_include": [&"scan_regex_include_line_edit"],
	&"scan_regex_exclude": [&"scan_regex_exclude_line_edit"],
}

var is_additional_ruleset := false:
	set(value):
		is_additional_ruleset = value
		# Additional ruleset editors have an extra column to support override buttons
		ruleset_properties_grid_container.columns = 3 if is_additional_ruleset else 2

		if is_additional_ruleset and _registry_scan_ruleset_override_buttons.is_empty():
			for ruleset_property in scan_ruleset_properties_to_root_edit_controls:
				var ruleset_root_control := scan_ruleset_properties_to_root_edit_controls[ruleset_property]
				var override_button := OVERRIDE_DEFAULT_SETTING_TOGGLE_BUTTON.instantiate()
				override_button.button_pressed = ruleset_property in DEFAULT_OVERRIDDEN_RULESET_PROPERTIES
				_registry_scan_ruleset_override_buttons[ruleset_property] = override_button
				ruleset_properties_grid_container.add_child(override_button)
				ruleset_properties_grid_container.move_child(override_button, ruleset_root_control.get_index())
				override_button.pressed.connect(_on_override_button_pressed)

		elif not is_additional_ruleset and not _registry_scan_ruleset_override_buttons.is_empty():
			for override_button: TextureButton in _registry_scan_ruleset_override_buttons.values():
				override_button.queue_free()
			_registry_scan_ruleset_override_buttons.clear()

		_update_overrides()

## Reference to another instance - only required for non-default ruleset editors.
## Allows using default values from this editor for non-overridden properties.
var default_ruleset_editor: ScanRulesetEditor:
	set(value):
		default_ruleset_editor = value
		default_ruleset_editor.inputs_changed.connect(_update_overrides)

var show_advanced_settings := false:
	set(value):
		show_advanced_settings = value
		class_restrictions_tab_container.show_advanced_settings = value
		scan_directories_tab_container.show_advanced_settings = value
		for property in ADVANCED_RULESET_PROPERTIES:
			for control: Control in advanced_ruleset_properties_to_controls[property]:
				control.visible = show_advanced_settings

		_update_overrides()

## Map ruleset property names to their override buttons
var _registry_scan_ruleset_override_buttons: Dictionary[String, TextureButton] = { }


func _ready() -> void:
	recursive_scan_check_box.add_theme_stylebox_override(&"focus", get_theme_stylebox(&"focus", &"LineEdit"))
	for override: StringName in [&"normal", &"hover", &"pressed", &"hover_pressed"]:
		recursive_scan_check_box.add_theme_stylebox_override(override, get_theme_stylebox(&"normal", &"LineEdit"))


func reset_properties(ruleset_settings: RegistryIO.RegistryScanRuleset) -> void:
	if is_additional_ruleset:
		for override_property in _registry_scan_ruleset_override_buttons:
			_registry_scan_ruleset_override_buttons[override_property].set_pressed_no_signal(ruleset_settings.override_properties.has(override_property))

	var update_resource_classes := not is_additional_ruleset or ruleset_settings.override_properties.has(&"class_restrictions")
	var update_scan_directories := not is_additional_ruleset or ruleset_settings.override_properties.has(&"scan_directories")
	var update_recursive_scan := not is_additional_ruleset or ruleset_settings.override_properties.has(&"recursive_scan")
	var update_allowed_file_extensions := not is_additional_ruleset or ruleset_settings.override_properties.has(&"allowed_file_extensions")
	var update_scan_regex_include := not is_additional_ruleset or ruleset_settings.override_properties.has(&"scan_regex_include")
	var update_scan_regex_exclude := not is_additional_ruleset or ruleset_settings.override_properties.has(&"scan_regex_exclude")

	if update_resource_classes:
		class_restrictions_tab_container.set_all_values(ruleset_settings.class_restrictions)
	if update_scan_directories:
		scan_directories_tab_container.set_all_values(ruleset_settings.scan_directories)
	if update_recursive_scan:
		recursive_scan_check_box.button_pressed = ruleset_settings.recursive_scan
	if update_allowed_file_extensions:
		allowed_file_extensions_line_edit.text = ",".join(ruleset_settings.allowed_file_extensions)
	if update_scan_regex_include:
		scan_regex_include_line_edit.text = ruleset_settings.scan_regex_include
	if update_scan_regex_exclude:
		scan_regex_exclude_line_edit.text = ruleset_settings.scan_regex_exclude

	# Trigger setters for already-set properties
	is_additional_ruleset = is_additional_ruleset
	show_advanced_settings = show_advanced_settings


static func are_any_advanced_ruleset_settings_set(ruleset_settings: RegistryIO.RegistryScanRuleset, default_ruleset_settings: RegistryIO.RegistryScanRuleset) -> bool:
	for advanced_ruleset_property in ADVANCED_RULESET_PROPERTIES:
		if ruleset_settings[advanced_ruleset_property] != default_ruleset_settings[advanced_ruleset_property]:
			return true
	return false


## Get the defined class strings for this ruleset editor, but only if it is the default editor or
## has overridden classes, otherwise an empty string.
func get_unique_class_strings() -> Array[String]:
	if (not is_additional_ruleset or _registry_scan_ruleset_override_buttons[&"class_restrictions"].button_pressed):
		var class_strings: Array[String] = []
		class_strings.assign(class_restrictions_tab_container.get_all_values(true))
		return class_strings
	else:
		return []


func _on_override_button_pressed() -> void:
	_update_overrides()
	inputs_changed.emit()


func _update_overrides() -> void:
	if not is_additional_ruleset or _registry_scan_ruleset_override_buttons.is_empty():
		return

	# Update all controls w/default values for non-overridden properties
	for property in scan_ruleset_properties_to_all_control_properties:
		var override_button := _registry_scan_ruleset_override_buttons[property]

		var is_property_overridden := override_button.button_pressed
		for control_property_name: StringName in scan_ruleset_properties_to_all_control_properties[property]:
			var our_control: Control = self[control_property_name]
			var default_control: Control = default_ruleset_editor[control_property_name]

			if our_control is LineEdit:
				if not is_property_overridden:
					our_control.text = default_control.text
				our_control.editable = is_property_overridden
			elif our_control is Button:
				if not is_property_overridden:
					our_control.set_pressed_no_signal(default_control.button_pressed)
				our_control.disabled = not is_property_overridden
			elif our_control is ScanInputsTabContainer:
				if not is_property_overridden:
					our_control.match_other_tab_inputs_container(default_control)
				our_control.disabled = not is_property_overridden

	# Only show advanced override buttons when advanced properties are enabled
	for property in ADVANCED_RULESET_PROPERTIES:
		var override_button := _registry_scan_ruleset_override_buttons[property]
		# Update all button visibilities
		override_button.visible = show_advanced_settings


func _build_ruleset() -> RegistryIO.RegistryScanRuleset:
	var ruleset := RegistryIO.RegistryScanRuleset.new()
	ruleset.class_restrictions.assign(class_restrictions_tab_container.get_all_values(true))
	ruleset.scan_directories.assign(scan_directories_tab_container.get_all_values(true))
	ruleset.recursive_scan = recursive_scan_check_box.button_pressed
	var file_extensions: Array[String] = []
	file_extensions.assign(allowed_file_extensions_line_edit.text.split(",", true))
	for i in file_extensions.size():
		file_extensions[i] = file_extensions[i].strip_edges()
	if file_extensions.size() == 1 and file_extensions[0].is_empty():
		file_extensions = []
	ruleset.allowed_file_extensions = file_extensions
	ruleset.scan_regex_include = scan_regex_include_line_edit.text.strip_edges()
	ruleset.scan_regex_exclude = scan_regex_exclude_line_edit.text.strip_edges()

	if is_additional_ruleset:
		for ruleset_property in _registry_scan_ruleset_override_buttons:
			if _registry_scan_ruleset_override_buttons[ruleset_property].button_pressed:
				ruleset.override_properties.append(ruleset_property)

	return ruleset


## Returns several tuples to represent validation states for:
## 1. Resource class checks
## 2. Scan directory checks
## 3. File extension checks
## 4. Regex include check
## 5. Regex exclude check
## Each tuple is in the form of: [ValidationSubState, StringName], which consists of the state of
## the validation for that check (info/success/warning/error) and the corresponding info message key
## (from NewRegistryDialog.INFO_MESSAGES). If that step was skipped or ignored, info is returned,
## but the message key will be empty.
## NOTE: although we could simplify this to return just the validation state, it may be better to
## keep this structure where we return the message keys separately so that we can more easily add
## additional, more specific warning/error messages in the future.
func _validate_fields() -> Array[Array]:
	var validation_messages: Array[Array] = []

	# Determine which properties should actually be validated (only default or non-overridden ones)
	var validate_resource_classes := not is_additional_ruleset or _registry_scan_ruleset_override_buttons[&"class_restrictions"].button_pressed
	var validate_scan_directories := not is_additional_ruleset or _registry_scan_ruleset_override_buttons[&"scan_directories"].button_pressed
	var validate_allowed_file_extensions := not is_additional_ruleset or _registry_scan_ruleset_override_buttons[&"allowed_file_extensions"].button_pressed
	var validate_scan_regex_include := not is_additional_ruleset or _registry_scan_ruleset_override_buttons[&"scan_regex_include"].button_pressed
	var validate_scan_regex_exclude := not is_additional_ruleset or _registry_scan_ruleset_override_buttons[&"scan_regex_exclude"].button_pressed

	# Resource classes
	if validate_resource_classes:
		var all_class_strings: Array[String] = []
		all_class_strings.assign(class_restrictions_tab_container.get_all_values(false))
		var class_restriction_input_validation_icons: Array[Texture2D] = []

		var all_classes_empty := true
		var all_classes_valid := true
		for class_string in all_class_strings:
			if class_string.is_empty():
				class_restriction_input_validation_icons.append(AnyIcon.get_class_icon(&"Resource"))
			else:
				all_classes_empty = false
				var is_class_valid := RegistryIO.is_resource_class_string(class_string)
				if is_class_valid:
					## TODO: Fix icon size in Godot 4.6 — https://github.com/godotengine/godot/pull/95817
					class_restriction_input_validation_icons.append(
						AnyIcon.get_script_icon(load(RegistryIO.unquote(class_string))) if RegistryIO.is_quoted_string(class_string) else AnyIcon.get_class_icon(class_string),
					)
				else:
					all_classes_valid = false
					class_restriction_input_validation_icons.append(AnyIcon.get_icon(&"MissingResource"))

		class_restrictions_tab_container.render_validation_results(class_restriction_input_validation_icons)

		if all_classes_empty:
			validation_messages.append([ValidationSubState.WARNING, &"class_empty"])
		elif all_classes_valid:
			validation_messages.append([ValidationSubState.SUCCESS, &"class_valid"])
		else:
			validation_messages.append([ValidationSubState.ERROR, &"class_invalid"])
	else:
		validation_messages.append([ValidationSubState.INFO, &""])

	# Scan directories
	if validate_scan_directories:
		var all_scan_paths: Array[String] = []
		all_scan_paths.assign(scan_directories_tab_container.get_all_values(true))
		if all_scan_paths.is_empty():
			validation_messages.append([ValidationSubState.INFO, &"scan_empty"])
		else:
			var all_paths_valid := true
			for scan_path in all_scan_paths:
				if not DirAccess.dir_exists_absolute(scan_path):
					all_paths_valid = false
					break

			if all_paths_valid:
				var has_root_dir := all_scan_paths.any(func(p: String) -> bool: return p == "res://")
				if has_root_dir:
					validation_messages.append([ValidationSubState.WARNING, &"scan_root_warning"])
				else:
					validation_messages.append([ValidationSubState.SUCCESS, &"scan_valid"])
			else:
				validation_messages.append([ValidationSubState.ERROR, &"scan_invalid"])
	else:
		validation_messages.append([ValidationSubState.INFO, &""])

	# Allowed file extensions
	if validate_allowed_file_extensions:
		var file_extensions: Array[String] = []
		file_extensions.assign(allowed_file_extensions_line_edit.text.split(",", true))
		if not file_extensions.is_empty() and not (file_extensions.size() == 1 and file_extensions[0].is_empty()):
			for i in file_extensions.size():
				file_extensions[i] = file_extensions[i].strip_edges()
			if file_extensions.any(func(s: String) -> bool: return s.is_empty()):
				validation_messages.append([ValidationSubState.ERROR, &"file_extensions_empty_extension"])
			elif file_extensions.any(func(s: String) -> bool: return not s.is_valid_filename()):
				validation_messages.append([ValidationSubState.ERROR, &"file_extensions_invalid_character"])
			else:
				validation_messages.append([ValidationSubState.SUCCESS, &"file_extensions_valid"])
		else:
			validation_messages.append([ValidationSubState.INFO, &"file_extensions_none"])
	else:
		validation_messages.append([ValidationSubState.INFO, &""])

	# Scan regex include filter
	if validate_scan_regex_include:
		var regex_include := scan_regex_include_line_edit.text.strip_edges()
		if not regex_include.is_empty():
			if RegistryIO.is_valid_regex_pattern(regex_include):
				validation_messages.append([ValidationSubState.SUCCESS, &"regex_include_valid"])
			else:
				validation_messages.append([ValidationSubState.ERROR, &"regex_include_invalid"])
		else:
			validation_messages.append([ValidationSubState.INFO, &""])
	else:
		validation_messages.append([ValidationSubState.INFO, &""])

	# Scan regex exclude filter
	if validate_scan_regex_exclude:
		var regex_exclude := scan_regex_exclude_line_edit.text.strip_edges()
		if not regex_exclude.is_empty():
			if RegistryIO.is_valid_regex_pattern(regex_exclude):
				validation_messages.append([ValidationSubState.SUCCESS, &"regex_exclude_valid"])
			else:
				validation_messages.append([ValidationSubState.ERROR, &"regex_exclude_invalid"])
		else:
			validation_messages.append([ValidationSubState.INFO, &""])
	else:
		validation_messages.append([ValidationSubState.INFO, &""])

	return validation_messages


func update_selected_class_restriction(class_restriction: String) -> void:
	class_restrictions_tab_container.update_selected_input_value(class_restriction)
	inputs_changed.emit()


func update_selected_scan_directory(scan_dir: String) -> void:
	scan_directories_tab_container.update_selected_input_value(scan_dir)
	inputs_changed.emit()


func _on_class_restrictions_tab_container_inputs_changed() -> void:
	inputs_changed.emit()


func _on_class_restrictions_tab_container_request_action(action: StringName, args: Variant) -> void:
	if action == ClassRestrictionInput.REQUEST_CLASS_RESTRICTION_CLASS_LIST_DIALOG_ACTION:
		request_class_restriction_class_list_dialog.emit(args)
	elif action == ClassRestrictionInput.REQUEST_CLASS_RESTRICTION_FILE_DIALOG_ACTION:
		request_class_restriction_file_dialog.emit(args)


func _on_scan_directories_tab_container_inputs_changed() -> void:
	inputs_changed.emit()


func _on_scan_directories_tab_container_request_action(action: StringName, args: Variant) -> void:
	if action == ScanDirectoryInput.REQUEST_SCAN_DIRECTORY_FILE_DIALOG_ACTION:
		request_scan_directory_file_dialog.emit(args)


func _on_recursive_scan_check_box_toggled(_toggled_on: bool) -> void:
	inputs_changed.emit()


func _on_allowed_file_extensions_line_edit_text_changed(_new_text: String) -> void:
	inputs_changed.emit()


func _on_scan_regex_include_line_edit_text_changed(_new_text: String) -> void:
	inputs_changed.emit()


func _on_scan_regex_exclude_line_edit_text_changed(_new_text: String) -> void:
	inputs_changed.emit()
