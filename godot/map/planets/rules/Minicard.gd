extends Control

export var minigame : Resource setget set_minigame

func set_minigame(v):
	minigame = v
	if not is_inside_tree():
		yield(self, "ready")
		
	var i = 0
	for rule in minigame.rules:
		var symbol = Sprite.new()
		symbol.position.y = 27
		symbol.position.x = 51.5 + (i-len(minigame.rules)/2.0+0.5)*48
		symbol.texture = rule.logo
		add_child(symbol)
		i += 1
		
