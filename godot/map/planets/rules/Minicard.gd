extends TextureRect

export var content : Resource setget set_content

func set_content(v):
	content = v
	if not is_inside_tree():
		yield(self, "ready")
		
	if content is GameMode:
		texture = load('res://assets/icon/minicards/card_minigame.png')
		var i = 0
		for rule in content.rules:
			var symbol = Sprite.new()
			symbol.position.y = 27
			symbol.position.x = 51.5 + (i-len(content.rules)/2.0+0.5)*48
			symbol.texture = rule.logo
			add_child(symbol)
			i += 1
	elif content is Mutator:
		texture = load('res://assets/icon/minicards/card_mutator.png')
		var symbol = Sprite.new()
		symbol.position.y = 27
		symbol.position.x = 51.5
		symbol.texture = load('res://assets/icon/minicards/mutators/'+content.name+'.png')
		add_child(symbol)
