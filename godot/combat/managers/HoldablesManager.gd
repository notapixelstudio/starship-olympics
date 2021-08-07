extends Node

func _ready():
	Events.connect('sth_collided_with_ship', self, '_on_sth_collided_with_ship')
	Events.connect('sth_is_overlapping_with_ship', self, '_on_sth_is_overlapping_with_ship')
	Events.connect('holdable_loaded', self, '_on_holdable_loaded')
	Events.connect('holdable_dropped', self, '_on_loadable_dropped')
	Events.connect('sths_bumped', self, '_on_sths_bumped')
	
func _on_sth_collided_with_ship(sth, ship: Ship) -> void:
	handle_collision(sth, ship)
	
func _on_sth_is_overlapping_with_ship(sth, ship: Ship) -> void:
	handle_collision(sth, ship)
	
func handle_collision(sth, ship: Ship) -> void:
	if traits.has_trait(sth, 'Holdable'):
		ship.load_holdable(sth)
	elif traits.has_trait(sth, 'Dropper') or sth is Wall and sth.type == Wall.TYPE.glass: # FIXME if Wall is refactored, it should use Dropper
		if ship.has_holdable():
			ship.drop_holdable()
			
func _on_sths_bumped(sth1, sth2) -> void:
	if sth1 is Ship and sth2 is Ship:
		sth1.swap_holdables_with(sth2)
		
func _on_holdable_loaded(holdable, ship):
	traits.get_trait(holdable, 'Holdable').remove()
	
func _on_loadable_dropped(holdable, ship):
	traits.get_trait(holdable, 'Holdable').restore()
