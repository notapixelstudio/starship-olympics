extends SessionPointIcon
class_name MedalIcon

@export var icons : Medals

func set_medal(v:String) -> void:
	if v == '':
		%Sprite2D.texture = null
		return
		
	%Sprite2D.texture = icons[v]
