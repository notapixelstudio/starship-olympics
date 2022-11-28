extends Resource

class_name ArenaStyle

export var battlefield_texture : Texture
export var battlefield_texture_offset = Vector2(0,0)
export var battlefield_texture_scale = Vector2(0.5,0.5)
export var battlefield_texture_rotation_degrees : float = 0.0
export var battlefield_fg_color : Color = Color(0.203922, 0.082353, 0.34902)
export var battlefield_bg_color : Color = Color(0.156863, 0.07451, 0.301961)
export(float, 0.0, 1.0) var battlefield_opacity = 0.9
export var wall_color : Color = Color8(208, 245, 295, 255)
export var wall_texture : Texture
export var bgm : AudioStream

func get_bgm():
	return
