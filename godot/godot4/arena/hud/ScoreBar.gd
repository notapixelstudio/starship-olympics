extends Bar

func set_max_value(v: float) -> void:
	super.set_max_value(v)
	%MaxScore.text = str(int(max_value))

func set_value(v: float) -> void:
	super.set_value(v)
	%Indicator.position.y = _get_max_size() - %Fill.size.y
	%Value.text = str(int(value))

func set_team(name:String) -> void:
	%Label.text = name
	
func set_species(species:Species) -> void:
	%Background.self_modulate = species.get_color_background()
	%Fill.modulate = species.get_color()
	%Label.modulate = species.get_color()
	%Value.modulate = species.get_color()
	%MaxScore.modulate = species.get_color()
	%MiniShip.texture = species.get_ship()
