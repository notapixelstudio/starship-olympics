@tool
extends Diamond

class_name HalfDiamond

@export var left := true: set = set_left
@export var left_texture : Texture2D
@export var right_texture : Texture2D

func set_left(v: bool) -> void:
	left = v
	if not is_inside_tree():
		await self.ready
	refresh()
	
func refresh():
	if left:
		$Sprite2D.texture = left_texture
		$SpriteEffect.texture = left_texture
		$SpriteEffect2.texture = left_texture
		$SpriteEffect3.texture = left_texture
		$Glow/Sprite2D.self_modulate = Color('#4c4eff93')
	else:
		$Sprite2D.texture = right_texture
		$SpriteEffect.texture = right_texture
		$SpriteEffect2.texture = right_texture
		$SpriteEffect3.texture = right_texture
		$Glow/Sprite2D.self_modulate = Color('#4ca24eff')
		
func _ready():
	super.set_points(3)
	refresh()
	
func on_collected_by(collector):
	pass
#	.on_collected_by(collector)
#	SoundEffects.play($AudioStreamPlayer2D)
