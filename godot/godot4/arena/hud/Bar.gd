extends Control
class_name Bar

@export var ticks_thickness := 3.0
@export var ticks_thickness_minor := 2.0
@export var thresholds := [{'value': 40}] # of {value: float, image: ImageTexture}

var max_value := 100.0 : set = set_max_value
var value := 0.0 : set = set_value

func set_max_value(v: float) -> void:
	max_value = v
	
func set_value(v: float) -> void:
	value = v
	var d = max(0, min(_get_max_size() / max_value * value, _get_max_size()))
	%Fill.size.y = d
	
func _get_max_size() -> float:
	return %Background.size.y
	
func _get_width() -> float:
	return %Background.size.x
	
	
func _ready() -> void:
	await get_tree().process_frame # FIXME is there a better way?
	set_value(value)
	
	# _draw() is automatically called once
	# this assumes that ticks should never be redrawn

func _draw() -> void:
	_draw_ticks()
	_draw_thresholds()
	
func _draw_ticks() -> void:
	for i in range(1, int(max_value)):
		# skip some ticks according to max score's order of magnitude
		if max_value > 99 and i%10 != 0:
			continue
		
		var d = _get_max_size() - round(i * _get_max_size()/max_value)
		var color = Color.BLACK
		var thickness
		if max_value <= 10 or (i%10 == 0 and max_value <= 100) or i%100 == 0:
			thickness = ticks_thickness
			color.a = 0.9
		else:
			thickness = ticks_thickness_minor
			color.a = 0.1
		draw_line(Vector2(0,d),Vector2(_get_width(),d), color, thickness)
		
func _draw_thresholds() -> void:
	for t in thresholds:
		var d = _get_max_size() - round(t['value'] * _get_max_size()/max_value)
		draw_line(Vector2(0,d),Vector2(_get_width(),d), Color.WHITE, ticks_thickness)
		draw_string(ThemeDB.get_project_theme().default_font, Vector2(_get_width()/2.0,d), str(t['value']), HORIZONTAL_ALIGNMENT_CENTER, -1)
