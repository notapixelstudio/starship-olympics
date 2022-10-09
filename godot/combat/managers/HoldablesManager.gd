extends Node

func _enter_tree():
	# listen to bumpers bumping
	Events.connect('sths_bumped', self, '_on_sths_bumped')
	
func _exit_tree():
	# stop listening when outside tree
	Events.disconnect('sths_bumped', self, '_on_sths_bumped')

func _ready():
	Events.connect('sth_collided_with_ship', self, '_on_sth_collided_with_ship')
	Events.connect('sth_is_overlapping_with_ship', self, '_on_sth_is_overlapping_with_ship')
	Events.connect('holdable_loaded', self, '_on_holdable_loaded')
	Events.connect('holdable_dropped', self, '_on_holdable_dropped')
	Events.connect("ship_damaged", self, "_on_ship_damaged")
	Events.connect("ship_died", self, "_on_ship_died")
	
func _on_sth_collided_with_ship(sth, ship: Ship) -> void:
	handle_collision(sth, ship)
	
func _on_sth_is_overlapping_with_ship(sth, ship: Ship) -> void:
	handle_collision(sth, ship)
	
func handle_collision(sth, ship: Ship) -> void:
	if traits.has_trait(sth, 'Holdable') and sth.is_loadable():
		ship.get_cargo().load_holdable(sth)
	elif traits.has_trait(sth, 'Dropper') or sth is Wall and sth.type == Wall.TYPE.glass: # FIXME if Wall is refactored, it should use Dropper
		if ship.get_cargo().has_holdable():
			ship.get_cargo().drop_holdable(sth)
			
func _on_sths_bumped(sth1, sth2) -> void:
	if sth1 is Ship and sth2 is Ship:
		if not sth1.has_cargo() and not sth2.has_cargo():
			# no actual swap has to occur, bail
			return
			
		var cargo1 = sth1.get_cargo()
		var cargo2 = sth2.get_cargo()
		
		# swap cargo
		var swap = cargo1.get_holdable()
		cargo1.set_holdable(cargo2.get_holdable())
		cargo2.set_holdable(swap)
		
		# swap holder statuses
		var swap_holder = sth1.is_holder()
		sth1.set_holder(sth2.is_holder())
		sth2.set_holder(swap_holder)
		
		# refresh appearance of cargoes
		cargo1.hide_holdable()
		cargo2.hide_holdable()
		cargo1.show_holdable()
		cargo2.show_holdable()
		
		Events.emit_signal("holdable_swapped", cargo1.get_holdable(), cargo2.get_holdable(), sth1, sth2)
		
func _on_ship_damaged(ship: Ship, hazard, author) -> void:
	if ship.get_cargo().has_holdable():
		ship.get_cargo().drop_holdable(ship)
		
func _on_ship_died(ship: Ship, author, for_good: bool) -> void:
	if ship.get_cargo().has_holdable():
		ship.get_cargo().drop_holdable(ship)
		
func _on_holdable_loaded(holdable, ship):
	traits.get_trait(holdable, 'Holdable').remove()
	ship.set_holder(true)
	
func _on_holdable_dropped(holdable, ship, cause):
	traits.get_trait(holdable, 'Holdable').restore()
	ship.set_holder(false)
