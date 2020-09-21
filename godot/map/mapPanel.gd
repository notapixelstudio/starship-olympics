extends Control

var species setget set_species
onready var sprite = $Sprite
onready var desc = $Label

var planet setget set_planet
var rest_text = "choose a planet"
var chosen = false setget set_chosen
onready var background = $Background
const deselected_modulate = Color(1,1,1,0.6)

func _ready():
	background.self_modulate = deselected_modulate

func set_chosen(chosen_):
	if not is_inside_tree():
		yield(self, "ready")
	chosen = chosen_
	if chosen:
		background.self_modulate = Color(1.1,1.1,1.1,1)
		$Tween.interpolate_property(self, 'rect_position',
			rect_position, Vector2(rect_position.x,-30), 0.5,
			Tween.TRANS_CUBIC, Tween.EASE_OUT)
		$Tween.start()
	else:
		background.self_modulate = deselected_modulate
		$Tween.interpolate_property(self, 'rect_position',
			rect_position, Vector2(rect_position.x,0), 0.5,
			Tween.TRANS_CUBIC, Tween.EASE_OUT)
		$Tween.start()
	
func set_species(species_):
	
	if not is_inside_tree():
		yield(self, "ready")
	if species_:
		species = species_
		sprite.texture = species.ship_off
		desc.text = rest_text
		background.modulate = species.color
	
func set_planet(planet_):
	if not is_inside_tree():
		yield(self, "ready")
	if planet_:
		planet = planet_
		desc.text = planet.name
	else:
		desc.text = rest_text
