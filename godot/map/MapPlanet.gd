tool
extends MapLocation

class_name MapPlanet

export (String, "invisible", "locked", "unlocked") var status setget set_status, get_status

export var planet : Resource setget set_planet # Planet
onready var sprite = $Sprite
export var active : bool = false setget set_active

var not_available = false setget set_availability

signal updated
signal unlocked

func get_id() -> String:
	return planet.id

func get_status():
	return status
	
func set_status(v):
	status = v
	if status == TheUnlocker.UNLOCKED:
		modulate = Color(1,1,1,1)
	elif status == TheUnlocker.LOCKED:
		modulate = Color(0,0,0,0.75)
	else:
		modulate = Color(0,0,0,0)
		
	$Label.text = status
	
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
	
func act(cursor):
	toggle_active()
	.act(cursor)
	if active:
		cursor.on_sth_pressed()
		$switch_on.play()
	else:
		$switch_off.play()
	emit_signal('updated', active)

func deactivate(cursor):
	set_active(false)
	$switch_off.play()
	emit_signal('updated', active)
	
func _ready():
	sprite.texture = planet.planet_sprite
	refresh()
	
	
func refresh():
	emit_signal('updated', active)
	if is_inside_tree():
		if active:
			$CheckBox.play('true')
		else:
			$CheckBox.play('empty')
			

func unlock():
	$AnimationPlayer.play("unlock")
	yield($AnimationPlayer, "animation_finished")
	emit_signal("unlocked")
