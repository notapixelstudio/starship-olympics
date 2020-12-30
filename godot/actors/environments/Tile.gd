extends Node2D

export var size = 1
export var points = 1

var conquering_ship : Ship
var owner_ship : Ship setget set_owner_ship

func set_owner_ship(v):
	owner_ship = v
	$Graphics.modulate = owner_ship.species.color
	
func _ready():
	scale = Vector2(size, size)
	$Graphics.position = Vector2(0,32/size)
	$Graphics/Label.text = '' if points == 1 else str(points)

func _process(delta):
	var bodies = $Area2D.get_overlapping_bodies()
	for body in bodies:
		if body is Ship and body != owner_ship and conquering_ship == null: # no self-conquest + former conqueror takes priority
			conquering_ship = body
			$AnimationPlayer.play('flip')
		
func conquest():
	set_owner_ship(conquering_ship)

func get_strategy(ship, distance, game_mode):
	if owner_ship == null and conquering_ship == null:
		return {"seek": points}
		
	if owner_ship != ship:
		return {"seek": points*1.5}
		
	return {}

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'flip':
		conquering_ship = null
		
