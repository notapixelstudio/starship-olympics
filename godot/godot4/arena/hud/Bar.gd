extends Control

@export var max_value := 100.0
@export var value := 0.0 : set = set_value

func set_value(v: float) -> void:
	value = v
	%Fill.size.y = size.y / max_value * value

func set_species(species:Species) -> void:
	modulate = species.get_color()
	
func _ready() -> void:
	%Label.size.x = size.x
	%Label.position.x = 0
	%Label.position.y = size.y
