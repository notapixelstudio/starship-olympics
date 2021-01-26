extends Resource

class_name Species

export (String) var id
export var species_id : int # This will be used to ordering them
export (String) var species_name
export (String) var tagline1
export (String) var tagline2
export (StreamTexture) var ship
export (StreamTexture) var ship_off
export (StreamTexture) var ship_w
export (Texture) var character_ok
export (Texture) var character_beaten


# color of the species
export var color : Color
export var color_2 : Color

func get_monogram():
	return species_name.left(1).to_upper()
	
