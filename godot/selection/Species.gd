extends Resource

class_name Species

@export var id: String
@export var species_id : int # This will be used to ordering them
@export var name: String
@export var tagline1: String
@export var tagline2: String
@export var ship: CompressedTexture2D
@export var ship_off: CompressedTexture2D
@export var ship_w: CompressedTexture2D
@export var character_ok: Texture2D
@export var character_beaten: Texture2D


# color of the species
@export var color : Color
@export var color_2 : Color

func get_id():
	return id
	
func get_monogram():
	return name.left(1).to_upper()
	
func get_ship() -> Texture2D:
	return ship

func get_color() -> Color:
	return color
	
