extends Component

class_name Conquerable

var species : Ship = null :
	get:
		return species # TODOConverter40 Copy here content of get_species
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_species

signal changed
func set_species(value):
	species = value
	emit_signal('changed')
	
func get_species():
	return species
	
