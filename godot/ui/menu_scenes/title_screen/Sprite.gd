extends Sprite2D

@export var species : Resource :
	get:
		return species # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_species

@onready var trail = $Trail


func set_species(value):
	species = value
	if is_inside_tree():
		await self.ready

	texture = species.ship_off
