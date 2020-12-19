extends Node

class_name Trait

var host

func _ready():
	host = get_parent()
	add_to_group('Trait_'+name)
	
# override this in your Trait subclass if you want a more complex validation
func validate():
	assert(is_in_group('Trait_'+name))
	
