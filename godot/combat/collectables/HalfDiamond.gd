tool
extends Diamond

class_name HalfDiamond

export var left := true setget set_left
export var left_texture : Texture
export var right_texture : Texture

func set_left(v: bool) -> void:
	left = v
	if left:
		$Sprite.texture = left_texture
		$SpriteEffect.texture = left_texture
		$SpriteEffect2.texture = left_texture
		$SpriteEffect3.texture = left_texture
	else:
		$Sprite.texture = right_texture
		$SpriteEffect.texture = right_texture
		$SpriteEffect2.texture = right_texture
		$SpriteEffect3.texture = right_texture
		
func _ready():
	.set_points(3)

func on_collected_by(collector):
	.on_collected_by(collector)
	SoundEffects.play($AudioStreamPlayer2D)
