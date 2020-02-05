extends Node2D

class_name Bar

const max_bar_width = 940
const ministar_width = 20
const margin_left = 20

const Star = preload('res://special_scenes/combat_UI/session_points/Star.tscn')

onready var progressbar = $ProgressBar
onready var sprite = $Ship/Sprite

onready var ministar_margin = ministar_width * global.win

var sprite_off
var sprite_on
var player
var new_position setget change_position

func initialize(player: PlayerStats, max_value, stars):
	var species = player.info.species
	progressbar.modulate = species.color
	progressbar.max_value = max_value
	progressbar.rect_size.x = max_bar_width - ministar_margin
	sprite_on = species.ship
	sprite_off = species.ship_off
	sprite.texture = sprite_off
	
	for i in range(global.win):
		var star = Star.instance()
		star.scale = Vector2(0.18,0.18)
		star.position.x = margin_left + max_bar_width - ministar_margin + i*ministar_width + 18
		star.position.y = 18
		
		if i < stars:
			star.won = true
		
		add_child(star)
	
func set_value(value):
	# round to 2 decimal digit
	if stepify(value, 0.01) > progressbar.value:
		sprite.texture = sprite_on
	else:
		sprite.texture = sprite_off
	progressbar.value = value
	$Ship.position.x = margin_left + progressbar.value*progressbar.rect_size.x/progressbar.max_value
	
func get_value():
	return progressbar.value

func change_position(new_value):
	new_position = new_value
	if position != new_position and not $Tween.is_active():
		$Tween.interpolate_property(self, "position", self.position, new_position, 0.5, 
			Tween.TRANS_CUBIC, Tween.EASE_IN, 0)
		$Tween.start()
	
