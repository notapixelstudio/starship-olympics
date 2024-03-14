extends RichTextLabel


func _ready():
	scroll_following = true
	
func log_line(message : String) -> void:
	var t = Time.get_ticks_msec()
	var h = int(floor(t / 3600000))
	var m = int(floor(t / 60000)) % 60
	var s = int(floor(t / 1000)) % 60
	var millis = t % 1000
	append_text("[color=#8ac4ff]%0*d:%0*d:%0*d.%0*d[/color] %s\n" % [2, h, 2, m, 2, s, 3, millis, message.replace('[b]', '[color=orange]').replace('[/b]','[/color]')])
