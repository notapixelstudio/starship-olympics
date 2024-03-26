extends RefCounted

var instance: Node
var overrides: Dictionary

signal changed

func _get_property_list() -> Array[Dictionary]:
	var properties := instance.get_property_list()
	var ret: Array[Dictionary]
	
	for property in properties:
		if property.usage != PROPERTY_USAGE_DEFAULT and not property.usage & (PROPERTY_USAGE_GROUP | PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SUBGROUP):
			continue
		
		if property.name == "position" or property.name == "script":
			continue
		
		ret.append(property)
	
	return ret

func _get(property: StringName) -> Variant:
	if property in overrides:
		return overrides[property]
	
	return instance.get(property)

func _set(property: StringName, value: Variant) -> bool:
	if instance.get(property) == value:
		overrides.erase(property)
	else:
		overrides[property] = value
	
	changed.emit()
	return true

func _property_can_revert(property: StringName) -> bool:
	return overrides.has(property)

func _property_get_revert(property: StringName) -> Variant:
	return instance.get(property)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		instance.free()
