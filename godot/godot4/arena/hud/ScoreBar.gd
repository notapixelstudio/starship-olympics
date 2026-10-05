extends Bar

@export var cpu_ship_image : Texture

var _players_list : Array[Player]

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
	
func set_players_list(players_list: Array[Player]) -> void:
	_players_list = players_list
	if len(players_list) == 1:
		var player = players_list[0]
		%Timer.queue_free()
		%Fill.material = null
		%Background.material = null
		%Background.self_modulate = player.get_species().get_color_background()
		%Fill.modulate = player.get_color()
		%Label.modulate = player.get_color()
		%Value.modulate = player.get_color()
		%MaxScore.modulate = player.get_color()
		%MiniShip.texture = player.get_ship_image()
		if player.is_cpu():
			%MiniShip.self_modulate = player.get_color()
			%MiniShip.texture = cpu_ship_image
	else:
		%Background.self_modulate = Color(0.2,0.2,0.2)
		var colors : Array[Color] = []
		for player in players_list:
			colors.append(player.get_color())
		%Fill.material.set_shader_parameter('colors', colors)
		%Fill.material.set_shader_parameter('number_of_colors', len(colors))
		%Fill.material.set_shader_parameter('stripe_size', 1.0/len(colors))
		%Background.material.set_shader_parameter('colors', colors)
		%Background.material.set_shader_parameter('number_of_colors', len(colors))
		%Background.material.set_shader_parameter('stripe_size', 0.85/len(colors))
		%MiniShip.texture = _players_list[_miniship_index].get_ship_image()
		if _players_list[_miniship_index].is_cpu():
			%MiniShip.self_modulate = _players_list[_miniship_index].get_color()
			%MiniShip.texture = cpu_ship_image
		
var _miniship_index := 1
func _on_miniship_timer_timeout() -> void:
	%MiniShip.texture = _players_list[_miniship_index].get_ship_image()
	if _players_list[_miniship_index].is_cpu():
		%MiniShip.self_modulate = _players_list[_miniship_index].get_color()
		%MiniShip.texture = cpu_ship_image
	# backwards
	_miniship_index -= 1
	if _miniship_index < 0:
		_miniship_index = len(_players_list)-1
