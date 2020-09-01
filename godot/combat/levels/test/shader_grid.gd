tool
extends Node2D

const Explosion = preload('res://actors/weapons/Explosion.tscn')


func _ready():
	yield(get_tree().create_timer(3.5), "timeout")
	var e = Explosion.instance()
	e.position = Vector2(633,283)
	add_child(e)
