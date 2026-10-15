extends Node3D

# a Trait is like a Godot group, but it is a full-fledged Node3D
# it could be used to define a common interface among nodes having the same Trait,
# or even common behaviour or validation

class_name Trait3D

@export var host : Node # this is the node the Trait is applied to, i.e., its parent

func get_host():
	return host
	
func _ready():
	if not host:
		host = get_parent()
	add_to_group('Trait_'+name)
	validate()
	
# override this in your Trait subclass if you want a more complex validation
func validate():
	assert(is_in_group('Trait_'+name))
	
