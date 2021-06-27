tool
extends RigidBody2D

class_name Fruit

export (String, 'pear', 'banana', 'grape', 'cherry') var type setget set_type
export var random = false

func set_type(v):
	type = v
	refresh()
	
func _ready():
	refresh()
	
func refresh():
	if random:
		type = ['pear', 'banana', 'grape', 'cherry'][randi()%4]
	if not is_inside_tree():
		yield(self, 'ready')
	$Sprite.texture = load('res://assets/sprites/fruits/'+type+'.png')
	
signal collected
