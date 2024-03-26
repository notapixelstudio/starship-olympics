extends Sprite2D

const OFFSET = 200

func _ready():
	randomize()
	position = Vector2(randf_range(OFFSET, get_viewport_rect().size.x - OFFSET), randf_range(OFFSET, get_viewport_rect().size.y - OFFSET))