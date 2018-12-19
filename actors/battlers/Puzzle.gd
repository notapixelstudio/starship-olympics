extends Area2D

var player_id

onready var skin = $Graphics

func initialize(puzzle_anim : PackedScene, ship : Node):
	skin.add_child(puzzle_anim.instance())	
	position = ship.position
	player_id = ship.player
