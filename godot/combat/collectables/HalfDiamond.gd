tool
extends Diamond

class_name HalfDiamond

export var left := true setget set_left
export var left_texture : Texture
export var right_texture : Texture

func set_left(v: bool) -> void:
	left = v
	if not is_inside_tree():
		yield(self, "ready")
	refresh()
	
func refresh():
	if left:
		$Sprite.texture = left_texture
		$SpriteEffect.texture = left_texture
		$SpriteEffect2.texture = left_texture
		$SpriteEffect3.texture = left_texture
		$Glow/Sprite.self_modulate = Color('#4c4eff93')
	else:
		$Sprite.texture = right_texture
		$SpriteEffect.texture = right_texture
		$SpriteEffect2.texture = right_texture
		$SpriteEffect3.texture = right_texture
		$Glow/Sprite.self_modulate = Color('#4ca24eff')
		
func _ready():
	.set_points(3)
	refresh()
	
func on_collected_by(collector):
	pass
#	.on_collected_by(collector)
#	SoundEffects.play($AudioStreamPlayer2D)
