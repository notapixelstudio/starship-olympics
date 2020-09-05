extends Node2D
var textures = {
	GameMode.BOMB_TYPE.classic: {
		'empty': preload('res://assets/sprites/interface/ammo_bomb_empty.png'),
		'full': preload('res://assets/sprites/interface/ammo_bomb_full.png'),
		'infinite': preload('res://assets/sprites/interface/ammo_bomb_infinite.png')
	},
	GameMode.BOMB_TYPE.ball: {
		'empty': preload('res://assets/sprites/interface/ammo_ball_empty.png'),
		'full': preload('res://assets/sprites/interface/ammo_ball_full.png'),
		'infinite': preload('res://assets/sprites/interface/ammo_ball_infinite.png')
	}}
const SEPARATION = 20

var type = GameMode.BOMB_TYPE.classic
var max_ammo = -1 setget set_max_ammo
var current_ammo = max_ammo

func set_max_ammo(v):
	for child in get_children():
		child.queue_free()
		
	max_ammo = v
	
	if max_ammo <= -1: # infinite
		# UGLY let's keep it for reference
		#var ammo = Sprite.new()
		#ammo.scale = Vector2(0.3, 0.3)
		#ammo.texture = textures[type]['infinite']
		#add_child(ammo)
		return
	
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
	if max_ammo <= -1: # infinite
		return
		
	for i in max_ammo:
		if i < current_ammo:
			get_child(i).texture = textures[type]['full']
		else:
			get_child(i).texture = textures[type]['empty']
			
