extends Treasure

@export var textures : Array[Texture]

signal grown

func _ready():
	set_texture(textures.pick_random())

func turn_small():
	%Sprite2D.scale = Vector2(0.1,0.1)
	
func grow():
	%GrowAnimation.play('Grow')

func _on_grow_animation_animation_finished(anim_name):
	if anim_name == 'Grow':
		grown.emit()
