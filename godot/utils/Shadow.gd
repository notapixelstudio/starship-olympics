extends Sprite2D

@export var sprite : NodePath :
	get:
		return sprite # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_sprite
@export var dy = 32
@export var auto_rotate := true

func set_sprite(v):
	sprite = v
	
func _ready():
	await get_tree().idle_frame # wait for e.g., ships to prepare
	redraw()
	
func redraw():
	if sprite:
		texture = get_node(sprite).texture
	
func _process(_delta):
	if auto_rotate:
		position = Vector2(0, dy).rotated(-global_rotation)
	else:
		position = Vector2(0, dy)
	
