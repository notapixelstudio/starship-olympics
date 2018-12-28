extends NinePatchRect

onready var tween = get_node("Tween")

func change_life_texture(new_texture): 
	get_node("life_texture").texture = new_texture
	
func get_lives(points):
	if points == 0:
		return
	var label = get_node("Number")
	tween.interpolate_property(label, "rect_scale", label.rect_scale, label.rect_scale *1.5, 0.5,tween.TRANS_BOUNCE, tween.EASE_IN)
	tween.interpolate_property(label, "rect_scale", label.rect_scale*1.5, label.rect_scale, 0.5,tween.TRANS_BOUNCE, tween.EASE_IN, 0.5)
	tween.start()
	label.text = str(points)