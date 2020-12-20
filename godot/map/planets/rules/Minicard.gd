extends Sprite

export var content : Resource setget set_content

func set_content(v):
	content = v
	if not is_inside_tree():
		yield(self, "ready")
		
	if content is GameMode:
		texture = content.icon
		$Shadow.texture = content.icon

