class_name GlowColor

var base_color = Color(1,1,1,1) setget set_base_color
var strength = 1 setget set_strength
var color = Color(1,1,1,1)

func set_base_color(v):
	base_color = v
	update()
	
func set_strength(v):
	strength = v
	update()
	
func _init(bc, s):
	set_base_color(bc)
	set_strength(s)
	
func update():
	color.r = base_color.r * strength
	color.g = base_color.g * strength
	color.b = base_color.b * strength
	
