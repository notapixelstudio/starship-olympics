@tool
extends Node2D
class_name FPSCounter

var count_label : Label
var units_label : Label

func _ready():
	count_label = Label.new()
	count_label.size = Vector2(200,70)
	count_label.position = Vector2(-100,-32)
	count_label.add_theme_font_size_override("font_size", 128)
	count_label.set_text('60')
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(count_label)
	
	units_label = Label.new()
	units_label.size = Vector2(200,26)
	units_label.position = Vector2(-100,120)
	units_label.add_theme_font_size_override("font_size", 48)
	units_label.set_text('FPS')
	units_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(units_label)
	
	if Engine.is_editor_hint():
		set_process(false)
	
func _process(delta):
	count_label.set_text("%d" % Engine.get_frames_per_second())
