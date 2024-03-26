extends Node2D

const AXIS = Vector2(-196, 0)


func _process(delta):
	var v = AXIS * %ChargeManager.get_charge_normalized()
	%ChargeBar.set_point_position(1, v)
	#$Graphics/ChargeBar/ChargeBackground.set_point_position(1, Vector2(v.x+4, v.y))
