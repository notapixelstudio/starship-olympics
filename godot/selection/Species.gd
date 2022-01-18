extends Resource

class_name Species

export (String) var id
export var species_id : int # This will be used to ordering them
export (String) var name
export (String) var tagline1
export (String) var tagline2
export (StreamTexture) var ship
export (StreamTexture) var ship_off
export (StreamTexture) var ship_w
export (Texture) var character_ok
export (Texture) var character_beaten
export (AudioStream) var voice


# color of the species
export var color : Color
export var color_2 : Color

func get_monogram():
	return name.left(1).to_upper()
	
