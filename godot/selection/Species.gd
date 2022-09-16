extends Resource

class_name Species

@export (String) var id
@export var species_id : int # This will be used to ordering them
@export (String) var name
@export (String) var tagline1
@export (String) var tagline2
@export (CompressedTexture2D) var ship
@export (CompressedTexture2D) var ship_off
@export (CompressedTexture2D) var ship_w
@export (Texture2D) var character_ok
@export (Texture2D) var character_beaten


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
	
