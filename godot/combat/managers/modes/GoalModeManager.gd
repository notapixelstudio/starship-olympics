extends ModeManager

signal score
func _on_goal_entered(ship, goal):
	if not(ship is Ship):
		return
		
	if ship.species == goal.species:
		emit_signal('score', ship.species, 1)
		#emit_signal('show_score', ship.species_template, 1, ship.global_position)
	else:
		emit_signal('score', ship.species, -1)
		#emit_signal('show_score', ship.species_template, -1, ship.global_position)
		