@tool
extends ScanTabInput

const ScanTabInput := preload("./scan_tab_input.gd")
const ScanDirectoryInput := preload("./scan_directory_input.gd")
const REQUEST_SCAN_DIRECTORY_FILE_DIALOG_ACTION := &"request_scan_directory_file_dialog"

@onready var scan_directory_line_edit: LineEdit = %ScanDirectoryLineEdit
@onready var scan_directory_filesystem_button: Button = %ScanDirectoryFilesystemButton


func _ready() -> void:
	if not Engine.is_editor_hint() or EditorInterface.get_edited_scene_root() == self:
		return

	scan_directory_line_edit.text_changed.connect(input_changed.emit.unbind(1))
	scan_directory_filesystem_button.pressed.connect(_on_directory_filesystem_button_pressed)

	disabled = disabled


func _set_disabled(value: bool) -> void:
	super(value)
	if is_node_ready():
		scan_directory_line_edit.editable = not disabled
		scan_directory_filesystem_button.disabled = disabled


func get_value() -> Variant:
	return scan_directory_line_edit.text.strip_edges()


func set_value(value: Variant) -> void:
	if typeof(value) == TYPE_STRING:
		scan_directory_line_edit.text = value


func reset_value() -> void:
	scan_directory_line_edit.text = ""


func render_validation_results(_args: Variant) -> void:
	pass


func _on_directory_filesystem_button_pressed() -> void:
	request_action.emit(REQUEST_SCAN_DIRECTORY_FILE_DIALOG_ACTION, scan_directory_line_edit.text)
