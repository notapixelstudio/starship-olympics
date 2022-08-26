extends Node2D

export var bar_texture : Texture
const bar_width := 26

func set_total(amount):
	for child in get_children():
		remove_child(child)
		
	for i in range(amount):
		var bar = Sprite.new()
		bar.texture = bar_texture
		bar.position.x = (i - amount/2.0 + 0.5) * bar_width
		add_child(bar)

func set_amount(amount):
	var i = 0
	for child in get_children():
		if i >= amount:
			child.modulate = Color(0.2,0.2,0.2,1)
		i += 1
