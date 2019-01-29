extends Sprite

const OFFSET = 200

func _ready():
	randomize()
	position = Vector2(rand_range(OFFSET, get_viewport_rect().size.x - OFFSET), rand_range(OFFSET, get_viewport_rect().size.y - OFFSET))