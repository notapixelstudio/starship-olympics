extends RichTextLabel


func _ready():
	bbcode_enabled = true
	scroll_following = true
	add_theme_font_override("normal_font", preload('fonts/fira_code/FiraCode-VF.ttf'))
	add_theme_font_size_override("normal_font_size", 40)
	
func log_line(message : String) -> void:
	var t = Time.get_ticks_msec()
	var h = int(floor(t / 3600000))
	var m = int(floor(t / 60000)) % 60
	var s = int(floor(t / 1000)) % 60
	var millis = t % 1000
	var color = '#8ac4ff' if Engine.is_in_physics_frame() else '#ff8ac4'
	var frame = "[color=#ff8ac4]Ph%d[/color]" % Engine.get_physics_frames() if Engine.is_in_physics_frame() else "[color=#8affc4]Pr%d[/color]" % Engine.get_process_frames()
	append_text("[color=8ac4ff]%0*d:%0*d:%0*d.%0*d[/color]-%s %s\n" % [2, h, 2, m, 2, s, 3, millis, frame, message.replace('[b]', '[color=orange]').replace('[/b]','[/color]')])
