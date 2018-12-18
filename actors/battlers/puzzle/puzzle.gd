extends Area2D

var origin
var player_id


onready var skin = $Graphics



func initialize(puzzle_anim : PackedScene):
	skin.add_child(puzzle_anim.instance())
	
	position = origin

	




# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
