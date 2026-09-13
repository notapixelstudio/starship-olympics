@tool
extends ItemList

signal registries_dropped(registries: Array[Registry])

# Behavior is implemented in `main_view.gd` to avoid unnecessary signals.
# This script exists only to override virtual methods related to drag and drop.


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if not get_rect().has_point(at_position):
		return false

	if typeof(data) != TYPE_DICTIONARY:
		return false

	var drop_type: StringName = data.get(&"type", &"")

	# Accept only expected payload types
	if drop_type != &"files" and drop_type != &"resource":
		return false

	# Validate content (must resolve to Registry instances)
	var regs := _extract_registries_from_drop(data, drop_type)
	return regs.size() > 0


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if typeof(data) != TYPE_DICTIONARY:
		return

	var drop_type: StringName = data.get(&"type", &"")
	var regs := _extract_registries_from_drop(data, drop_type)

	if regs.is_empty():
		return

	registries_dropped.emit(regs)


func _extract_registries_from_drop(data: Dictionary, drop_type: StringName) -> Array[Registry]:
	var out: Array[Registry] = []

	if drop_type == &"files":
		# Godot editor "files" payload generally carries an Array of paths in `files`
		var files: Array = data.get(&"files", [])
		for path: Variant in files:
			if typeof(path) != TYPE_STRING:
				continue
			var res := load(path)
			if res is Registry:
				out.append(res)

	elif drop_type == &"resource":
		var res: Variant = data.get(&"resource", null)
		if res is Registry:
			out.append(res)

	return out
