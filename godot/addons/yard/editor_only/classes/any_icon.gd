# MIT License
# Copyright (c) 2025 Patou (xorblo-doitus)
# https://github.com/xorblo-doitus/AnyIcon

@tool
extends Object
## A singleton providing easy access to icons representing classes and types, from values or members.
##
## Use [method get_variant_icon] for the highest abstraction when getting an icon by value.
## There are some methods related to preperty types too, such as [method get_property_icon_from_dict].

## If true, methods can return a generated icon for union of classes
## by concatenating thes icons from left to right.
## Else, fallback is used.
## This can happen for example when getting the icon of a property dict,
## for instance with the material property, whose class_name is
## "CanvasItemMaterial,ShaderMaterial".
static var allow_generating_union_icons: bool = true

## Shortcut for [method EditorInterface.get_base_control].
static var base_control: Control = EditorInterface.get_base_control() if Engine.is_editor_hint() else Control.new():
	set(new):
		printerr("AnyIcon.base_control is read-only.")
## The icon displayed when no valid icon is found.
static var icon_not_found: Texture2D = base_control.get_theme_icon(&""):
	set(new):
		printerr("AnyIcon.icon_not_found is read-only.")

static var _ICON_ANNOTATION_REGEX := RegEx.create_from_string(
	r"""@icon\s*?\((?:[^#]*?(?:)*?(?:#.*)*?)*?(?<delimiter>"+|'+)(?<path>.*?)\k<delimiter>(?:.|\n)*?\)""",
)

# static var _union_cache: Dictionary[String, ImageTexture] = {}
static var _union_cache: Dictionary = { }


## This static method returns the icon that represents the type of the passed value.
## It works for everything: Built-in types and classes, custom classes with or
## without class_name.
static func get_variant_icon(variant: Variant, fallback: StringName = &"") -> Texture2D:
	var type := typeof(variant) as Variant.Type

	if type == TYPE_OBJECT:
		if is_instance_valid(variant): # Need the check because of type hints
			return get_object_icon(variant, fallback)
		else:
			return get_icon(&"Object")

	return get_type_icon(type, fallback)


## Returns all the icon of properties with a matching [param usage_mask] as a dictionary
## with property names as keys and [Texture2D]s as values.
## [br][br][b]Note:[/b] See also [method get_property_icon] and [method get_property_icon_from_dict]
## [br][br][b]Note:[/b] In Godot 4.4, you can enable the dictionary typing of this method by
## commenting the actual typed declaration and uncommenting the typed ones in the addon
## code.
static func get_all_property_icons(object: Object, usage_mask: int = PROPERTY_USAGE_SCRIPT_VARIABLE) -> Dictionary:
	#static func get_all_property_icons(object: Object, usage_mask: int = PROPERTY_USAGE_SCRIPT_VARIABLE) -> Dictionary[StringName, Texture2D]:
	#var result: Dictionary[StringName, Texture2D] = {}
	var result: Dictionary = { }

	for property_dict in object.get_property_list():
		if property_dict["usage"] & usage_mask:
			result[property_dict["name"]] = get_property_icon_from_dict(property_dict)

	return result


## Returns the icon of the type/class of a property on an object.
## [br][br][b]Note:[/b] If you are getting the icon of all the properties on this object,
## use [method get_all_property_icons] instead for better performances.
static func get_property_icon(object: Object, property_name: StringName, fallback: StringName = &"") -> Texture2D:
	for property_dict in object.get_property_list():
		if property_dict["name"] == property_name:
			return get_property_icon_from_dict(property_dict)

	return get_icon(fallback)


## Returns the icon of the type/class of a property.
## [param property_dict] is one of the dictionary returned by
## [method Object.get_property_list].
## [br][br][b]Note:[/b] If you are getting the icon of all the properties on an object,
## use [method get_all_property_icons] instead for better performances.
static func get_property_icon_from_dict(property_dict: Dictionary, fallback: StringName = &"") -> Texture2D:
	var type: Variant.Type = property_dict["type"]

	if type == TYPE_OBJECT:
		if property_dict["class_name"]:
			return get_class_icon(property_dict["class_name"], fallback)
		return get_icon(&"Object")

	return get_type_icon(type, fallback)


static func get_object_icon(object: Object, fallback: StringName = &"") -> Texture2D:
	if object == null or not is_instance_valid(object):
		return get_icon(&"Object")

	if object is Script:
		return get_script_icon(object, fallback)

	var script: Script = object.get_script()
	if script:
		return get_script_icon(script, fallback)

	return get_builtin_class_icon(object.get_class())


static func get_script_icon(script: Script, fallback: StringName = &"") -> Texture2D:
	var current_script: Script = script
	while current_script:
		if current_script.get_global_name():
			return get_class_icon(current_script.get_global_name(), fallback)

		var match_ := _ICON_ANNOTATION_REGEX.search(current_script.source_code)
		if match_ and match_.get_string("path"):
			return load(match_.get_string("path"))

		current_script = current_script.get_base_script()

	return get_builtin_class_icon(script.get_instance_base_type())


## Generates an icon for a comma-separated union of classes
## by concatenating thes icons from left to right.
## [br][br][b]Example:[/b] "CanvasItemMaterial,ShaderMaterial"
static func generate_union_class_icon(union_name: String, fallback: StringName = &"") -> ImageTexture:
	if union_name in _union_cache:
		return _union_cache[union_name]

	var image: Image = Image.create_empty(1, 1, true, Image.FORMAT_RGBA8)

	for name in union_name.split(","):
		var icon: Texture2D = get_class_icon(name, fallback)
		var add_at_x: int = image.get_width()
		image.crop(
			image.get_width() + icon.get_width(),
			max(image.get_height(), icon.get_height()),
		)
		image.blit_rect(
			icon.get_image(),
			Rect2i(Vector2i.ZERO, icon.get_size()),
			Vector2i(add_at_x, 0),
		)

	_union_cache[union_name] = ImageTexture.create_from_image(image)
	return _union_cache[union_name]


## See also [method get_custom_class_icon], [method get_builtin_class_icon]
## and [method get_type_icon].
static func get_class_icon(name: StringName, fallback: StringName = &"") -> Texture2D:
	if ClassDB.class_exists(name):
		return get_builtin_class_icon(name, fallback)

	return get_custom_class_icon(name, fallback)


## See also [method get_class_icon]
static func get_custom_class_icon(name: StringName, fallback: StringName = &"") -> Texture2D:
	if allow_generating_union_icons and "," in name:
		return generate_union_class_icon(name, fallback)

	var found: bool = true
	var global_class_list := ProjectSettings.get_global_class_list()

	while found:
		found = false

		for class_ in global_class_list:
			if class_["class"] == name:
				if class_["icon"]:
					return load(class_["icon"])
				else:
					name = class_["base"]

					if ClassDB.class_exists(name):
						return get_builtin_class_icon(name, fallback)

					found = true
					break # break the for

	# This can happen for invlaid name, such as a type union
	# (ex: "CanvasItemMaterial,ShaderMaterial")
	return get_icon(fallback)


static func get_type_icon(type: Variant.Type, fallback: StringName = &"") -> Texture2D:
	if type == TYPE_NIL:
		return get_icon(&"Nil")

	if 0 <= type and type < TYPE_MAX:
		return get_icon(type_string(type))

	return get_icon(fallback)


## See also [method get_class_icon]
static func get_builtin_class_icon(class_name_: StringName, fallback: StringName = &"") -> Texture2D:
	if allow_generating_union_icons and "," in class_name_:
		return generate_union_class_icon(class_name_, fallback)

	var result: Texture2D = get_icon(class_name_)

	while result == icon_not_found and ClassDB.class_exists(class_name_):
		class_name_ = ClassDB.get_parent_class(class_name_)
		result = get_icon(class_name_)

	if result == icon_not_found and fallback:
		return get_icon(fallback)

	return result


## Like [method TypeAndAnyIcon.get_icon], but returns the [param fallback]
## if no icon is found.
static func try_get_icon(name: StringName, fallback: StringName, theme_type: StringName = &"EditorIcons") -> Texture2D:
	var result: Texture2D = get_icon(name, theme_type)
	if result == icon_not_found:
		return get_icon(fallback, theme_type)
	return result


## Returns an icon of the EditorTheme. See [method Control.get_theme_icon].
static func get_icon(name: StringName, theme_type: StringName = &"EditorIcons") -> Texture2D:
	return base_control.get_theme_icon(name, theme_type)


## Returns true if the passed [param icon] is not [member icon_not_found].
static func is_valid(icon: Texture2D) -> bool:
	return icon != icon_not_found


func _init() -> void:
	push_error("Can't instantiate TypeAndAnyIcon. This class is a singleton.")
	free()
