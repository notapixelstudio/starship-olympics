extends Sprite

export var sprite : NodePath setget set_sprite
export var dy = 32

func set_sprite(v):
	sprite = v
	
func _ready():
	yield(get_tree(), "idle_frame") # wait for e.g., ships to prepare
	redraw()
	
func redraw():
	texture = get_node(sprite).texture
	
func _process(_delta):
	position = Vector2(0, dy).rotated(-global_rotation)
	
