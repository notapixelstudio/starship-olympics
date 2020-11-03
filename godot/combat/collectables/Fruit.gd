tool
extends RigidBody2D

export (String, 'pear', 'banana', 'grape', 'cherry') var type setget set_type

func set_type(v):
	type = v
	if not is_inside_tree():
		yield(self, 'ready')
	$Sprite.texture = load('res://assets/sprites/fruits/'+type+'.png')
	
