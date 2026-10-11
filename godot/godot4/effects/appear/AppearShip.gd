extends "res://godot4/effects/appear/Appear.gd"

var _player : Player

func set_player(v:Player) -> void:
	_player = v

func _done():
	%RepealField.send_shockwave(_player)
	super()
