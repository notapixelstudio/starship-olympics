extends Bar

var _species_list : Array[Species]

func set_max_value(v: float) -> void:
	super.set_max_value(v)
	%MaxScore.text = str(int(max_value))

func set_value(v: float) -> void:
	super.set_value(v)
	%Indicator.position.y = _get_max_size() - %Fill.size.y
	%Value.text = str(int(value))

func set_team(name:String) -> void:
	if name == 'GG': # co-op team name
		%Label.text = ''
	else:
		%Label.text = name
	
func set_species_list(species_list: Array[Species]) -> void:
	_species_list = species_list
	if len(species_list) == 1:
		var species = species_list[0]
		%Timer.queue_free()
		%Fill.material = null
		%Background.material = null
		%Background.self_modulate = species.get_color_background()
		%Fill.modulate = species.get_color()
		%Label.modulate = species.get_color()
		%Value.modulate = species.get_color()
		%MaxScore.modulate = species.get_color()
		%MiniShip.texture = species.get_ship()
	else:
		%Background.self_modulate = Color(0.2,0.2,0.2)
		var colors : Array[Color] = []
		for species in species_list:
			colors.append(species.get_color())
		%Fill.material.set_shader_parameter('colors', colors)
		%Fill.material.set_shader_parameter('number_of_colors', len(colors))
		%Fill.material.set_shader_parameter('stripe_size', 1.0/len(colors))
		%Background.material.set_shader_parameter('colors', colors)
		%Background.material.set_shader_parameter('number_of_colors', len(colors))
		%Background.material.set_shader_parameter('stripe_size', 1.0/len(colors))
		%MiniShip.texture = _species_list[_miniship_index].get_ship()
		
var _miniship_index := 1
func _on_miniship_timer_timeout() -> void:
	%MiniShip.texture = _species_list[_miniship_index].get_ship()
	# backwards
	_miniship_index -= 1
	if _miniship_index < 0:
		_miniship_index = len(_species_list)-1
