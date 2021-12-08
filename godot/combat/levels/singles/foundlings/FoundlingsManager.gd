extends Node

func _ready():
	yield(get_tree(), "idle_frame") # wait for variants to settle
	var aliens = Homeworld.COLORS.keys()
	aliens.shuffle()
	var i = 0
	for homeworld in get_tree().get_nodes_in_group('homeworld'):
		homeworld.set_kind(aliens[i])
		i = (i+1) % len(aliens)
		
	Events.connect("planet_reached", self, '_on_planet_reached')
	
func _on_planet_reached(planet, sth):
	if not(planet is Homeworld):
		return
		
	if sth is Ship:
		var cargo = sth.get_cargo()
		
		if cargo.has_holdable():
			var holdable = cargo.get_holdable()
			if holdable is Alien and holdable.get_kind() == planet.get_kind():
				cargo.empty()
				global.the_match.add_score(sth.get_player().id, 1)
				global.arena.show_msg(sth.get_player().species, 1, sth.position)
	elif sth is Alien:
		if sth.get_kind() == planet.get_kind():
			sth.queue_free()
			if sth.get_player() != null:
				global.the_match.add_score(sth.get_player().id, 1)
				global.arena.show_msg(sth.get_player().species, 1, sth.position)
