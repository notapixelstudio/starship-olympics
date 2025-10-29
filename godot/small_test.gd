extends Node2D

class User:
	var createdAt: String
	var name: String
	var avatar: String
	var id: int

var user: Dictionary = {
 createdAt = "1601239812",
 name = "William",
 avatar = "https://google.com/images/avatar",
 id = 0
}
static func class_to_dict(instance: Object) -> Dictionary:
	var dict := {}
	for prop in instance.get_property_list():
		var prop_name = prop.name
		# We only want to serialize the script variables.
		if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			dict[prop_name] = instance.get(prop_name)
	return dict
	
# Converts a Dictionary to a class instance.
static func dict_to_class(dict: Dictionary, instance: Object) -> Object:
	for key in dict:
		if instance.has_method("set"):
			instance.set(key, dict[key])
	return instance
	
func _ready():
	var u: User = dict_to_class(user, User.new())
	print(u.name) # will print "William"
	print(JSON.stringify(u))
	#print(class_to_json(u)) # will print '{avatar=...}'
