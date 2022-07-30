extends Sprite

export var sprite : NodePath setget set_sprite
export var dy = 32
export var auto_rotate := true

func set_sprite(v):
	sprite = v
	
func _ready():
	yield(get_tree(), "idle_frame") # wait for e.g., ships to prepare
	redraw()
	
func redraw():
	texture = get_node(sprite).texture
	
func _process(_delta):
	if auto_rotate:
		position = Vector2(0, dy).rotated(-global_rotation)
	else:
		position = Vector2(0, dy)
	
