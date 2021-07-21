tool
extends MapLocation

class_name MapPlanet

export (String, "invisible", "locked", "unlocked") var status setget set_status, get_status

export var planet : Resource setget set_planet # Planet
onready var sprite = $Sprite

var not_available = false setget set_availability

signal updated
signal unlocked

func get_id() -> String:
	return planet.id

func get_status():
	return status
	
func set_status(v):
	status = v
	$Lock.visible = false
	if Engine.editor_hint:
		$Sprite.modulate = Color(1,1,1,1)
	elif status == TheUnlocker.UNLOCKED:
		$Sprite.modulate = Color(1,1,1,1)
	elif status == TheUnlocker.LOCKED:
		$Sprite.modulate = Color(0,0,0,0.5)
		$Lock.visible = true
	else:
		$Sprite.modulate = Color(0,0,0,0)
		
	$DebugLabel.text = status
	
func set_availability(value):
	not_available = value
	if sprite:
		$NA.visible = not_available
		
func set_planet(value):
	planet = value
	
func act(cursor):
	.act(cursor)
	cursor.on_sth_pressed(status == TheUnlocker.UNLOCKED or status == TheUnlocker.LOCKED and cursor.is_winner())
	
func _ready():
	if planet:
		sprite.texture = planet.planet_sprite
		$Label.text = planet.name
	
func unlock():
	$AnimationPlayer.play("unlock")
	yield($AnimationPlayer, "animation_finished")
	emit_signal("unlocked")

func on_hover():
	$Label.visible = true
	
func on_blur():
	$Label.visible = false
	
