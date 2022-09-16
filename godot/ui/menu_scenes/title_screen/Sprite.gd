extends Sprite2D

@export var species : Resource :
	get:
		return species # TODOConverter40 Non existent get function 
	set(mod_value):
		species = mod_value
		if is_inside_tree():
			await self.ready
		texture = species.ship_off

@onready var trail = $Trail

