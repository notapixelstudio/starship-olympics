extends Resource

class_name SpeciesTemplate

export (int) var id
export (String) var species_name
export (StreamTexture) var ship
export (Texture) var character_ok
export (Texture) var character_beaten
export (Texture) var select_rect

export var species_id : int

# color of the species
export var color : Color

# graphic and animations of battlers
export var ship_anim : PackedScene

func change_rect(color:Color):
    select_rect.modulate = color
