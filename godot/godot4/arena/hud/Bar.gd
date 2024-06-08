extends Control

@export var max_value := 100.0 : set = set_max_value
@export var value := 0.0 : set = set_value
@export var ticks_thickness := 3.0
@export var ticks_thickness_minor := 1.5

func set_max_value(v: float) -> void:
	max_value = v
	
func set_value(v: float) -> void:
	value = v
	%Value.text = str(int(value))
	var d = max(0, min(_get_max_size() / max_value * value, _get_max_size()))
	%Fill.size.y = d
	%Indicator.position.y = _get_max_size() - d

func set_team(name:String) -> void:
	%Label.text = name
	
func set_species(species:Species) -> void:
	%Background.self_modulate = species.get_color_background()
	%Fill.modulate = species.get_color()
	%Label.modulate = species.get_color()
	%Value.modulate = species.get_color()
	%MiniShip.texture = species.get_ship()
	
func _get_max_size() -> float:
	return %Background.size.y
	
func _get_width() -> float:
	return %Background.size.x
	
	
func _ready() -> void:
	await get_tree().process_frame # FIXME is there a better way?
	set_value(value)
	%Value.size.x = _get_width()
	
	# _draw() is automatically called once
	# this assumes that ticks should never be redrawn

func _draw() -> void:
	_draw_ticks()
	
func _draw_ticks() -> void:
	for i in range(1, int(max_value)):
		# skip some ticks according to max score's order of magnitude
		if max_value > 99 and i%10 != 0:
			continue
		
		var d = _get_max_size() - round(i * _get_max_size()/max_value)
		var color = Color.BLACK
		var thickness
		if max_value <= 10 or (i%10 == 0 and max_value < 100) or i%100 == 0:
			thickness = ticks_thickness
			color.a = 0.9
		else:
			thickness = ticks_thickness_minor
			color.a = 0.5
		draw_line(Vector2(0,d),Vector2(_get_width(),d), color, thickness)
		
