extends "res://godot4/effects/appear/Appear.gd"

var _player : Player

func set_player(v:Player) -> void:
	_player = v
	
	if _player.is_cpu():
		%Sprite2D.self_modulate = _player.get_species().get_color()

func _done():
	%RepealField.send_shockwave()# _player) - no points for you
	super()
