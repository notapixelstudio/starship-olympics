tool
extends RigidBody2D

class_name Ball

const GRAB_DISTANCE = 72

export (String, 'crown', 'basket', 'soccer', 'tennis', 'heart', 'star', 'negacrown') var type setget set_type

var impulse := 0.0

func set_type(v):
	type = v
	refresh()
	
func _ready():
	if type == 'soccer':
		impulse = 5
	set_physics_process(false)
	refresh()
	
func refresh():
	if not is_inside_tree():
		yield(self, 'ready')
	$Sprite.texture = load('res://assets/sprites/balls/'+type+'.png')
	
func place_and_push(dropper, velocity) -> void:
	global_position = dropper.global_position
	global_position = dropper.global_position + Vector2(GRAB_DISTANCE,0).rotated(dropper.global_rotation)
	
	linear_velocity = velocity
	if type == 'soccer':
		linear_velocity *= 1.5
		
	activate()

func activate():
	set_physics_process(impulse > 0)
	
func _physics_process(_delta):
	apply_central_impulse(impulse*Vector2(1,0).rotated(linear_velocity.angle()))
	
func get_strategy(ship, distance, game_mode):
	return {"seek": 10}
	
func get_texture():
	return $Sprite.texture
	
func show_on_top():
	return type == 'crown' or type == 'negacrown'
	
func is_rotatable():
	return type != 'crown' and type != 'negacrown' and type != 'star'

func is_loadable():
	return is_inside_tree()
	
func has_type(t):
	return type == t
	
