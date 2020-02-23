tool

extends MapCell

class_name MapPlanet

export var planet : Resource setget set_planet
onready var sprite = $Sprite

export var active : bool = false setget set_active

var not_available = false setget set_availability

func set_availability(value):
	not_available = value
	if sprite:
		$NA.visible = not_available
		
func set_planet(value):
	planet = value
	refresh()
	
func set_active(value):
	active = value
	refresh()
	
func toggle_active():
	set_active(not active)
	
signal toggled
func act(cursor):
	toggle_active()
	.act(cursor)
	cursor.on_sth_pressed()
	if active:
		$switch_on.play()
	else:
		$switch_off.play()
	emit_signal('toggled', active)
	
func _ready():
	sprite.texture = planet.planet_sprite
	refresh()
	
func refresh():
	if is_inside_tree():
		if active:
			$CheckBox.play('true')
		else:
			$CheckBox.play('empty')
			