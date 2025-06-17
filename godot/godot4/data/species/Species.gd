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
@export var color_background : Color
@export var color_accent : Color

func get_id():
	return id
	
func get_monogram():
	return name.left(1).to_upper()
	
func get_ship() -> Texture2D:
	return ship

func get_ship_silhouette() -> Texture2D:
	return ship_w

func get_color() -> Color:
	return color
	
func get_color_secondary() -> Color:
	return color_2
	
func get_color_background() -> Color:
	return color_background
	
func get_color_accent() -> Color:
	return color_accent
	
func get_character_image() -> Texture:
	return character_ok
	
func get_progressive() -> int:
	return species_id
	
static func get_from_id(species_id: String) -> Species:
	return load("res://godot4/data/species/"+species_id+".tres")

static func get_all_unlocked() -> Array[Species]:
	var ordered_species : Array[Species] = []
	var unlocked_species = TheUnlocker.get_unlocked_list("species")
	for id in unlocked_species:
		ordered_species.append(Species.get_from_id(id))
	ordered_species.sort_custom(Species.compare)
	return ordered_species

static func compare(a:Species, b:Species):
	return a.get_progressive() < b.get_progressive()
