@tool
extends ScanTabInput

const ScanTabInput := preload("./scan_tab_input.gd")
const ClassRestrictionInput := preload("./class_restriction_input.gd")
const REQUEST_CLASS_RESTRICTION_CLASS_LIST_DIALOG_ACTION := &"request_class_restriction_class_list_dialog"
const REQUEST_CLASS_RESTRICTION_FILE_DIALOG_ACTION := &"request_class_restriction_file_dialog"

@onready var class_restriction_line_edit: LineEdit = %ClassRestrictionLineEdit
@onready var class_list_dialog_button: Button = %ClassListDialogButton
@onready var class_filesystem_button: Button = %ClassFilesystemButton


func _ready() -> void:
	if not Engine.is_editor_hint() or EditorInterface.get_edited_scene_root() == self:
		return

	class_restriction_line_edit.text_changed.connect(input_changed.emit.unbind(1))
	class_list_dialog_button.pressed.connect(_on_class_list_dialog_button_pressed)
	class_filesystem_button.pressed.connect(_on_class_filesystem_button_pressed)

	disabled = disabled


func _set_disabled(value: bool) -> void:
	super(value)
	if is_node_ready():
		class_restriction_line_edit.editable = not disabled
		class_list_dialog_button.disabled = disabled
		class_filesystem_button.disabled = disabled


func get_value() -> Variant:
	return class_restriction_line_edit.text.strip_edges()


func set_value(value: Variant) -> void:
	if typeof(value) == TYPE_STRING or typeof(value) == TYPE_STRING_NAME:
		class_restriction_line_edit.text = value


func reset_value() -> void:
	class_restriction_line_edit.text = ""


## We should receive an updated class icon texture to render
func render_validation_results(args: Variant) -> void:
	if args is Texture2D:
		class_restriction_line_edit.right_icon = args


func _on_class_list_dialog_button_pressed() -> void:
	request_action.emit(REQUEST_CLASS_RESTRICTION_CLASS_LIST_DIALOG_ACTION, class_restriction_line_edit.text)


func _on_class_filesystem_button_pressed() -> void:
	request_action.emit(REQUEST_CLASS_RESTRICTION_FILE_DIALOG_ACTION, class_restriction_line_edit.text)
