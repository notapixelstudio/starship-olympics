extends Component

var species : Ship = null: get = get_species, set = set_species

func set_species(value):
	species = value
	
func get_species():
	return species
	