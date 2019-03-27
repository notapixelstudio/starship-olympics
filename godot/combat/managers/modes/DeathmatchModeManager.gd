extends ModeManager

signal score
func _on_ship_killed(ship : Ship, killer : Ship):
	if not enabled:
		return
		
	if killer and killer.species != ship.species:
		emit_signal('score', killer.species, 5)
	
	# by design, no points detracted for self kills or death by environment
	# the respawn downtime is a sufficient reason to keep yourself alive
	# if points are never detracted the game tends more towards its completion
