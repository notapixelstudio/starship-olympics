@tool
extends EditorInspectorPlugin

const Namespace := preload("res://addons/yard/editor_only/namespace.gd")
const EditorPropertyOptionWrapper := Namespace.EditorPropertyOptionWrapper
const MultiOptionEditorProperty := Namespace.MultiOptionEditorProperty


func _can_handle(_object: Object) -> bool:
	return true


func _parse_property(object: Object, type: Variant.Type, name: String, hint: PropertyHint, hint_text: String, _usage: int, _wide: bool) -> bool:
	if hint != Registry.PROPERTY_HINT_CUSTOM:
		return false

	var parts: PackedStringArray = hint_text.split(",")
	var registry_path: String = parts[0]

	if not (registry_path.begins_with("res://") or registry_path.begins_with("uid://")):
		return false

	var registry: Registry = load(registry_path)
	if not registry is Registry:
		return false

	var show_empty: bool = parts.size() > 1 and parts[1].strip_edges() == "true" # when unspecified: false
	var allow_duplicates: bool = parts.size() <= 2 or parts[2].strip_edges() != "false" # when unspecified: true

	var string_ids: Array[String] = []
	for id in registry.get_all_string_ids():
		string_ids.append(str(id))

	match type:
		TYPE_STRING, TYPE_STRING_NAME:
			var current_value: String = str(object.get(name))
			var editor: EditorProperty = EditorPropertyOptionWrapper.new(current_value, string_ids, show_empty, type)
			add_property_editor(name, editor, false, name.capitalize())
			return true
		TYPE_ARRAY:
			var array_val: Variant = object.get(name)
			if array_val is Array and array_val.is_typed() and array_val.get_typed_builtin() in [TYPE_STRING, TYPE_STRING_NAME]:
				var editor: MultiOptionEditorProperty = MultiOptionEditorProperty.new()
				editor.initialize(array_val, string_ids, name.capitalize(), allow_duplicates, array_val.get_typed_builtin())
				add_property_editor(name, editor, false, name.capitalize())
				return true

	return false
