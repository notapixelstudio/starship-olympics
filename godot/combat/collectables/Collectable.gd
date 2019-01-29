extends Area2D
tool

class_name Collectable

var player_id
export var puzzle_anim : PackedScene 

onready var skin = $Graphics

func _ready():
	initialize(puzzle_anim)
	
func initialize(new_puzzle_anim : PackedScene):
	puzzle_anim = new_puzzle_anim
	$Graphics.add_child(puzzle_anim.instance())