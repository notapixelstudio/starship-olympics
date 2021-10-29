extends Node

func _ready():
	Events.connect("planet_reached", self, '_on_planet_reached')
	
func _on_planet_reached(planet, sth):
	if not(planet is Homeworld) or not(sth is Ship):
		return
		
	var cargo = sth.get_cargo()
	
	if cargo.has_holdable():
		var holdable = cargo.get_holdable()
		if holdable is Alien:# and holdable.kind == planet.get_kind()
			cargo.empty()
