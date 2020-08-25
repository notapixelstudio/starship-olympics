extends Node2D

const empty_texture = preload('res://assets/sprites/interface/ammo_empty.png')
const full_texture = preload('res://assets/sprites/interface/ammo_full.png')

const SEPARATION = 20

var max_ammo = -1 setget set_max_ammo
var current_ammo = max_ammo

func set_max_ammo(v):
	for child in get_children():
		child.queue_free()
		
	max_ammo = v
	for i in max_ammo:
		var ammo = Sprite.new()
		ammo.scale = Vector2(0.3, 0.3)
		ammo.position.x = (i-(max_ammo-1)/2.0)*SEPARATION
		add_child(ammo)
		
	refresh()
	
func shot():
	current_ammo = max(0, current_ammo-1)
	refresh()
	
func reload():
	current_ammo = min(max_ammo, current_ammo+1)
	refresh()
	
func replenish():
	current_ammo = max_ammo
	refresh()
	
func refresh():
	for i in max_ammo:
		if i < current_ammo:
			get_child(i).texture = full_texture
		else:
			get_child(i).texture = empty_texture
			
