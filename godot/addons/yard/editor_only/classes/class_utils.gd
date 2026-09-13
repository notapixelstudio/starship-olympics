extends Object

# MIT LICENSE
# Copyright (c) 2025 Wagner GFX
# https://github.com/WagnerGFX/gdscript_utilities

## Provides utility functions to handle types directly, instead of instances or variables.
##
## This class supports user-created [Script]s and Native Classes like [Object], [Resource] and [Node].
## [br]Scripts without class_name, as inner classes or generated in runtime are [b]NOT[/b] supported,
## they will probably show as a basic type, like [RefCounted] or [GDScript].
## [br]Only Native Classes exposed to GDScript are supported.

const _SCRIPT_BODY_EDITOR := "static func eval():
	var class_type = %s
	var _class_object : %s
	return class_type"

const _SCRIPT_BODY_RUNTIME := "static func eval(): return %s"


## Returns the inheritance tree of a class type reference or name.
static func get_inheritance_list(class_type: Variant, include_self: bool = false) -> Array[String]:
	var final_class_name: String

	if class_type is String:
		final_class_name = class_type

	elif class_type is Script or class_type is Object:
		final_class_name = get_type_name(class_type)

	# Script name > Base Script name > Base Native Class name
	if final_class_name == "" and class_type is Script:
		include_self = true
		var base_script: Script = class_type.get_base_script()

		if base_script:
			final_class_name = get_type_name(base_script)
		else:
			final_class_name = class_type.get_instance_base_type()

	var inheritance_list: Array[String]
	if include_self:
		inheritance_list.append(final_class_name)

	# Search custom script
	var keep_searching := true
	var parent_script := final_class_name

	while keep_searching:
		keep_searching = false

		for inner_script in ProjectSettings.get_global_class_list():
			if inner_script["class"] == parent_script:
				parent_script = inner_script["base"]
				inheritance_list.append(parent_script)
				keep_searching = true
				break

	# Search native node classes
	keep_searching = true

	while keep_searching:
		keep_searching = false
		parent_script = ClassDB.get_parent_class(parent_script)

		if not parent_script == "":
			inheritance_list.append(parent_script)
			keep_searching = true

	return inheritance_list


static func get_script_inheritance_list(script: Script, include_self: bool = false) -> Array[Script]:
	var result: Array[Script] = []
	var current: Script = script.get_base_script() if not include_self else script

	while current:
		result.append(current)
		current = current.get_base_script()

	return result


## Returns the full inheritance chain of [param script] as an array of strings.
## [br]Script ancestors are represented by their global class name, or by their
## [code]resource_path[/code] if no [code]class_name[/code] is declared.
## Native class ancestors are appended after the script chain.
## [br]If [param include_self] is [code]true[/code], [param script] itself is included first.
static func get_script_inheritance_list_strings(script: Script, include_self: bool = false) -> Array[String]:
	var inheritance_list_builtin := get_inheritance_list(script)
	var inheritance_script_list := get_script_inheritance_list(script, include_self)
	var inheritance_script_list_string: Array[String]
	for s: Script in inheritance_script_list:
		inheritance_script_list_string.append(str(s.get_global_name()) if s.get_global_name() else s.resource_path)

	return inheritance_script_list_string + inheritance_list_builtin


## Sorts an array of class identifiers so that parent classes always appear before child classes.
## [br]Each element can be a class name or builtin (e.g. [code]"Node"[/code])
## or a script path (e.g. [code]"res://my_class.gd"[/code]).
## [br]Returns a new sorted array. Elements that cannot be resolved are kept in place.
static func sort_by_inheritance(classes_names: Array[String]) -> Array[String]:
	var n := classes_names.size()
	if n <= 1:
		return classes_names.duplicate()

	# Returns all ancestor class names/paths for a given entry, with caching
	var cache := { }
	var ancestors_of := func(entry: String) -> Array:
		if entry not in cache:
			cache[entry] = (get_script_inheritance_list_strings(load(entry), false)
				if entry.begins_with("res://")
				else get_inheritance_list(entry, false) )
		return cache[entry]

	# Build graph: edge i→j means class[i] is ancestor of class[j] (must come before)
	var in_degree := PackedInt32Array()
	in_degree.resize(n)
	var adj: Array[Array] = []
	adj.resize(n)
	for i in n:
		adj[i] = []
		for j in n:
			if i != j and ancestors_of.call(classes_names[j]).has(classes_names[i]):
				adj[i].append(j)
				in_degree[j] += 1

	# Kahn's topological sort
	var queue: Array[int]
	var result: Array[String] = []
	queue.assign(range(n).filter(func(i: int) -> bool: return in_degree[i] == 0))
	while not queue.is_empty():
		var idx: int = queue.pop_front()
		result.append(classes_names[idx])
		for j: int in adj[idx]:
			in_degree[j] -= 1
			if in_degree[j] == 0:
				queue.append(j)

	return result


## Given that [param property_info] is a class descriptor from get_property_list(),
## returns the class name or the script path if no name declared.
static func get_class_name_or_path_from_prop(property_info: Dictionary) -> String:
	if not is_class_property(property_info):
		return ""

	var prop_name: String = property_info[&"name"]
	var hint_string: String = property_info[&"hint_string"]
	if not hint_string.begins_with("res://"):
		return prop_name

	var script := load(hint_string) as Script
	if not (script and script is Script):
		return prop_name

	var global_name := script.get_global_name()
	return str(global_name) if global_name else hint_string


## Returns [code]true[/code] if [param property_info] is a class descriptor entry
## from [method Object.get_property_list].
static func is_class_property(property_info: Dictionary) -> bool:
	return (
		property_info[&"name"] != ""
		and property_info[&"type"] == TYPE_NIL
		and property_info[&"usage"] & (PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_GROUP) != 0
		and property_info[&"hint_string"] != ""
	)


## Returns the type name of any given type or it's instance.
## [br][br][param obj]: Accepts anything other than built-in Variant types directly.
## [br] This includes Native Classes, user-defined Scripts,
## instances of Node/Resource or any Variant value, including [code]null[/code].
static func get_type_name(obj: Variant) -> String:
	var class_type_name: String

	if (obj is Node or obj is Resource) and obj.get_script():
		obj = obj.get_script()

	if obj is Script:
		if is_engine_version_equal_or_newer(4, 3):
			class_type_name = obj.get_global_name()
		else:
			for inner_script in ProjectSettings.get_global_class_list():
				if inner_script["path"] == obj.resource_path:
					class_type_name = inner_script["class"]
					break

		if class_type_name.is_empty() and obj.get_base_script():
			# recursion until we get a global name or hit a built-in class
			class_type_name = get_type_name(obj.get_base_script())

		if class_type_name.is_empty():
			class_type_name = obj.get_class()

	elif obj is Object and is_native(obj):
		# TODO: replace properly.
		#class_type_name = GDScriptUtilities.native_classes.get((obj as Object).get_instance_id(), "")
		return "GDScriptNativeClass"

	elif obj is Object:
		class_type_name = obj.get_class()

	elif typeof(obj) == TYPE_ARRAY:
		class_type_name = _get_typed_array_name(obj)

	elif typeof(obj) == TYPE_DICTIONARY:
		class_type_name = _get_typed_dictionary_name(obj)

	else:
		class_type_name = type_string(typeof(obj))

	return class_type_name


## Returns an [Object] that represents the type of a Native Class or user-defined Script.
## [br]It produces a result similar to [code]var class_type = Node as Object[/code].
static func get_type(classname: String) -> Object:
	var result: Object

	if is_script(classname):
		for inner_script in ProjectSettings.get_global_class_list():
			if inner_script["class"] == classname:
				result = load(inner_script["path"])
				break

	elif (
		ClassDB.class_exists(classname)
		and ClassDB.is_class_enabled(classname)
		#and not GDScriptUtilities.native_classes_invalid.has(classname)
	):
		result = get_type_unsafe(classname)

	return result


## Used by [method get_type] and core plugin features. Executes with minimal validation.
static func get_type_unsafe(classname: String) -> Object:
	var _script := GDScript.new()
	if Engine.is_editor_hint():
		_script.set_source_code(_SCRIPT_BODY_EDITOR % [classname, classname])
	else:
		_script.set_source_code(_SCRIPT_BODY_RUNTIME % [classname])

	var error := _script.reload()
	var result: Object

	if error == OK:
		result = _script.eval()

	return result


## Checks if [param class_type] is the same or inherits from [param base_class_type].
## [br]Similar to [method Object.is_class], but searches the entire inheritance,
## including Native Classes and user-created Scripts.
## [br][br]Both parameters accept String names, instances and types of Scripts or Native Classes.
static func is_class_of(class_type: Variant, base_class_type: Variant) -> bool:
	var class_type_name: String
	if class_type is String or class_type is StringName:
		class_type_name = class_type
	elif class_type is Object:
		class_type_name = get_type_name(class_type)
	else:
		return false

	var base_class_type_name := ""
	if base_class_type is String or base_class_type is StringName:
		base_class_type_name = base_class_type
	elif base_class_type is Object:
		base_class_type_name = get_type_name(base_class_type)
	else:
		return false

	if not is_valid(class_type_name) or not is_valid(base_class_type_name):
		return false

	var inheritance_list := get_inheritance_list(class_type_name, true)
	return inheritance_list.has(base_class_type_name)


## Checks if [param class_type] is a reference or name that represents a valid Native Class.
static func is_native(class_type: Variant) -> bool:
	if not class_type:
		return false

	if class_type is String or class_type is StringName:
		return ClassDB.class_exists(class_type) and ClassDB.is_class_enabled(class_type)
	elif class_type is Object and (class_type as Object).get_class() == "GDScriptNativeClass":
		return true
	else:
		return false


## Checks if a [param class_type] is a reference or name that matches an existing user-defined Script.
## Similar to [code]is GDScript[/code], but also accepts string names.
static func is_script(script: Variant) -> bool:
	var script_name: String

	if script is Script:
		return true

	elif script is String:
		script_name = script

	if not script or script_name.is_empty():
		return false

	var result := false
	for inner_script in ProjectSettings.get_global_class_list():
		if inner_script["class"] == script_name:
			result = true
			break

	return result


# WARNING: hacky
## Returns an array of property names declared in a Native Class or user-defined Script, based on a reference or name.
## [br][br][param obj]: Accepts anything other than built-in Variant types directly.
## [br] This includes Native Classes, user-defined Scripts, instances of Node/Resource.
static func get_class_property_names(class_type: Variant) -> Array[String]:
	var prop_names: Array[String] = []
	if not class_type:
		return prop_names

	if is_native(class_type):
		var classname: String = class_type if class_type is String else get_type_name(class_type)
		var props_native := ClassDB.class_get_property_list(classname)
		for p in props_native:
			if not p.name.is_empty() and not p.type == TYPE_NIL:
				prop_names.append(p.name)

	elif is_script(class_type):
		var obj: Script = class_type if class_type is Script else get_type(class_type)
		if obj is Script:
			var script := obj as Script
			var script_props := script.get_script_property_list()
			#print(script_props)
			for p in script_props:
				if not p.name.is_empty() and not p.type == TYPE_NIL:
					prop_names.append(p.name)

		var props := obj.get_property_list()
		for p in props:
			if not p.name.is_empty() and not p.type == TYPE_NIL:
				prop_names.append(p.name)

	return prop_names


## Checks if a given type ID represents any built-in type except TYPE_OBJECT.
## Can receive other type IDs to exclude.
static func is_type_builtin(type_id: Variant.Type, exclusions: Array[int] = []) -> bool:
	if type_id == TYPE_OBJECT:
		return false

	return not exclusions.has(type_id)


## Checks if a string represents an existing Native Class or user-defined Script
static func is_valid(classname: String) -> bool:
	return is_script(classname) or is_native(classname)


static func _get_typed_array_name(value: Array) -> String:
	var array_name := type_string(typeof(value))

	# Not a typed Array
	if not value.is_typed():
		return array_name

	var typed_array_name := ""
	if is_type_builtin(value.get_typed_builtin()):
		typed_array_name = type_string(value.get_typed_builtin())
	elif value.get_typed_script() != null:
		typed_array_name = get_type_name(value.get_typed_script())
	else:
		typed_array_name = value.get_typed_class_name()

	return "%s[%s]" % [array_name, typed_array_name]


static func _get_typed_dictionary_name(value: Dictionary) -> String:
	var dictionary_name := type_string(typeof(value))

	# Before Godot v4.4
	if is_engine_version_older(4, 4):
		return dictionary_name

	# Not a typed Dictionary
	if not value.is_typed():
		return dictionary_name

	# Key
	var dictionary_key_type_name := ""
	if not value.is_typed_key():
		dictionary_key_type_name = "any"
	elif is_type_builtin(value.get_typed_key_builtin()):
		dictionary_key_type_name = type_string(value.get_typed_key_builtin())
	elif value.get_typed_key_script() != null:
		dictionary_key_type_name = get_type_name(value.get_typed_key_script())
	else:
		dictionary_key_type_name = value.get_typed_key_class_name()

	# Value
	var dictionary_value_type_name := ""
	if not value.is_typed_value():
		dictionary_value_type_name = "any"
	elif is_type_builtin(value.get_typed_value_builtin()):
		dictionary_value_type_name = type_string(value.get_typed_value_builtin())
	elif value.get_typed_value_script() != null:
		dictionary_value_type_name = get_type_name(value.get_typed_value_script())
	else:
		dictionary_value_type_name = value.get_typed_value_class_name()

	return "%s[%s,%s]" % [dictionary_name, dictionary_key_type_name, dictionary_value_type_name]


## Return true if the current engine version is equal or newer compared to the values provided
static func is_engine_version_equal_or_newer(major: int, minor: int = 0, patch: int = 0) -> bool:
	var engine_ver: Dictionary = Engine.get_version_info()
	return engine_ver.major >= major and engine_ver.minor >= minor and engine_ver.patch >= patch


## Return true if the current engine version is older compared to the values provided
static func is_engine_version_older(major: int, minor: int = 0, patch: int = 0) -> bool:
	return not is_engine_version_equal_or_newer(major, minor, patch)


## Returns all declared types of a property as an array of strings (e.g. ["int"], ["BaseMaterial3D","ShaderMaterial"], ...).
static func get_property_declared_types(target: Variant, property_name: String) -> Array:
	var types := []
	var target_obj: Object = null
	if target is String:
		target_obj = get_type(target)
	elif target is Object:
		target_obj = target
	else:
		return types
	if not target_obj or not target_obj.has_method("get_property_list"):
		return types
	for p: Dictionary in target_obj.get_property_list():
		if p["name"] != property_name:
			continue
		if p.has("type_name") and p["type_name"] != "":
			types.append(str(p["type_name"]))
		elif p.has("type"):
			var t := int(p["type"])
			if t != TYPE_OBJECT:
				types.append(type_string(t))
			else:
				if p.has("hint_string") and str(p["hint_string"]) != "":
					for s in str(p["hint_string"]).split(","):
						types.append(s.strip_edges())
				elif p.has("class") and str(p["class"]) != "":
					types.append(str(p["class"]))
				else:
					types.append("Object")
		elif p.has("hint_string") and str(p["hint_string"]) != "":
			for s in str(p["hint_string"]).split(","):
				types.append(s.strip_edges())
	return types


## Returns the default (zero/empty) value for a given built-in Variant type.
static func get_type_builtin_default_value(type_id: Variant.Type) -> Variant:
	match type_id:
		TYPE_AABB:
			return AABB()
		TYPE_ARRAY:
			return Array()
		TYPE_BASIS:
			return Basis()
		TYPE_BOOL:
			return bool() # false
		TYPE_CALLABLE:
			return Callable()
		TYPE_COLOR:
			return Color() # black
		TYPE_DICTIONARY:
			return Dictionary()
		TYPE_FLOAT:
			return float()
		TYPE_INT:
			return int()
		TYPE_NIL:
			return null
		TYPE_NODE_PATH:
			return NodePath()
		TYPE_OBJECT:
			return Object.new()
		TYPE_PACKED_BYTE_ARRAY:
			return PackedByteArray()
		TYPE_PACKED_COLOR_ARRAY:
			return PackedColorArray()
		TYPE_PACKED_FLOAT32_ARRAY:
			return PackedFloat32Array()
		TYPE_PACKED_FLOAT64_ARRAY:
			return PackedFloat64Array()
		TYPE_PACKED_INT32_ARRAY:
			return PackedInt32Array()
		TYPE_PACKED_INT64_ARRAY:
			return PackedInt64Array()
		TYPE_PACKED_STRING_ARRAY:
			return PackedStringArray()
		TYPE_PACKED_VECTOR2_ARRAY:
			return PackedVector2Array()
		TYPE_PACKED_VECTOR3_ARRAY:
			return PackedVector3Array()
		TYPE_PACKED_VECTOR4_ARRAY:
			return PackedVector4Array()
		TYPE_PLANE:
			return Plane()
		TYPE_PROJECTION:
			return Projection()
		TYPE_QUATERNION:
			return Quaternion()
		TYPE_RECT2:
			return Rect2()
		TYPE_RECT2I:
			return Rect2i()
		TYPE_RID:
			return RID()
		TYPE_SIGNAL:
			return Signal()
		TYPE_STRING:
			return String()
		TYPE_STRING_NAME:
			return StringName()
		TYPE_TRANSFORM2D:
			return Transform2D()
		TYPE_TRANSFORM3D:
			return Transform3D()
		TYPE_VECTOR2:
			return Vector2()
		TYPE_VECTOR2I:
			return Vector2i()
		TYPE_VECTOR3:
			return Vector3()
		TYPE_VECTOR3I:
			return Vector3i()
		TYPE_VECTOR4:
			return Vector4()
		TYPE_VECTOR4I:
			return Vector4i()
		_:
			return null
