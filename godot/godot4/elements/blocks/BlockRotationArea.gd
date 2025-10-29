@tool
extends Area2D
class_name BlockRotationArea

@export var cw := true : set = set_cw

func set_cw(v:bool) -> void:
	cw = v
	%Arrow.flip_h = not cw

func is_cw() -> bool:
	return cw

func _process(delta: float) -> void:
	var on = false
	for area in get_overlapping_areas():
		if area.get('host') is Ship and area.get('host').is_holding_block():
			on = true
			break
		
	if on:
		%Arrow.modulate = Color(0,0,0,0.8)
		%Background.modulate = Color('#ffbf8e14')
	else:
		%Background.modulate = Color('#ffaf5e10')
		%Arrow.modulate = Color(0,0,0,0.3)
