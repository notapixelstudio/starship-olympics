extends Component

class_name Conquerable

var species : Ship = null: get = get_species, set = set_species

signal changed
func set_species(value):
	species = value
	emit_signal('changed')
	
func get_species():
	return species
	
