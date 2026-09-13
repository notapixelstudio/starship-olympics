@tool
#class_name EditorThemeUtils

static var editor_theme: Theme:
	get:
		return EditorInterface.get_editor_theme()

static var base_margin: int:
	get:
		return editor_theme.get_constant("base_margin", "Editor")

static var class_icon_size: int:
	get:
		return editor_theme.get_constant("class_icon_size", "Editor")

static var scale: float:
	get:
		return EditorInterface.get_editor_scale()

static var color_error: Color:
	get:
		return editor_theme.get_color("error_color", "Editor")

static var color_warning: Color:
	get:
		return editor_theme.get_color("warning_color", "Editor")

static var color_success: Color:
	get:
		return editor_theme.get_color("success_color", "Editor")


static func get_base_color(p_dimness_ofs: float = 0.0, p_saturation_mult: float = 1.0) -> Color:
	var settings := EditorInterface.get_editor_settings()

	var c: Color = settings.get_setting("interface/theme/base_color")
	var contrast: float = float(settings.get_setting("interface/theme/contrast"))

	c.v = clamp(lerp(c.v, 0.0, contrast * p_dimness_ofs), 0.0, 1.0)
	c.s = c.s * p_saturation_mult
	return c
