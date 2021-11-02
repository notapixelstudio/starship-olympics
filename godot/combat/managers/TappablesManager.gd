extends Node

var active_tappables := {}

func _ready():
	Events.connect("tappable_entered", self, '_on_tappable_entered')
	Events.connect("tappable_exited", self, '_on_tappable_exited')
	Events.connect("tap", self, '_on_tap')
	
func _on_tappable_entered(tappable, ship : Ship):
	# activate another tappable only if there are no older ones
	if not active_tappables.has(ship):
		active_tappables[ship] = tappable
		tappable.show_tap_preview(ship)
	
func _on_tappable_exited(tappable, ship : Ship):
	if active_tappables.has(ship):
		active_tappables[ship].hide_tap_preview()
		active_tappables.erase(ship)
		
		# check if we will be in another tappable
		yield(get_tree(), "idle_frame")
		ship.recheck_colliding()

func _on_tap(ship : Ship):
	if active_tappables.has(ship):
		var tappable = active_tappables[ship]
		tappable.tap(ship)
		Events.emit_signal("sth_tapped", ship, tappable)
