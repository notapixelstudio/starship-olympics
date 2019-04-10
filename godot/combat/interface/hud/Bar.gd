extends Node2D

class_name Bar

onready var progressbar = $ProgressBar
onready var sprite = $Ship/Sprite

var sprite_off
var sprite_on
var player
var new_position setget change_position

func initialize(species_template: SpeciesTemplate, max_value):
	progressbar.modulate = species_template.color
	progressbar.max_value = max_value
	sprite_on = species_template.ship
	sprite_off = species_template.ship_off
	sprite.texture = sprite_off
	
	
func set_value(value):
	# round to 2 decimal digit
	if stepify(value, 0.01) > progressbar.value:
		sprite.texture = sprite_on
	else:
		sprite.texture = sprite_off
	progressbar.value = value
	$Ship.position.x = 20 + progressbar.value*progressbar.rect_size.x/progressbar.max_value
	
func get_value():
	return progressbar.value

func change_position(new_value):
	new_position = new_value
	if position != new_position and not $Tween.is_active():
		$Tween.interpolate_property(self, "position", self.position, new_position, 0.5, 
			Tween.TRANS_CUBIC, Tween.EASE_IN, 0)
		$Tween.start()
	
