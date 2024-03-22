extends Treasure

@export var textures : Array[Texture]


func _ready():
	set_texture(textures.pick_random())
