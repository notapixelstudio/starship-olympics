extends Component

var species : Ship = null :
	get:
		return species # TODOConverter40 Copy here content of get_species
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_species

func set_species(value):
	species = value
	
func get_species():
	return species
	