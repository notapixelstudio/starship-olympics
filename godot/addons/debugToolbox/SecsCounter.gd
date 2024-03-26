@tool
extends Node2D
class_name SecsCounter

var count_label : Label

var _time := 0

func _ready():
	count_label = Label.new()
	count_label.size = Vector2(200,70)
	count_label.position = Vector2(-100,-32)
	count_label.add_theme_font_size_override("font_size", 128)
	count_label.set_text('00')
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(count_label)
	
	if not Engine.is_editor_hint():
		var timer = Timer.new()
		timer.autostart = true
		timer.timeout.connect(_on_timeout)
		add_child(timer)
	
func _on_timeout():
	_time += 1
	count_label.set_text("%02d" % _time)
