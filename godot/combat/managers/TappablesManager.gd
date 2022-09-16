extends Node

var active_tappables := {}

func _enter_tree():
	Events.connect("tappable_entered",Callable(self,'_on_tappable_entered'))
	Events.connect("tappable_exited",Callable(self,'_on_tappable_exited'))
	Events.connect("tap",Callable(self,'_on_tap'))
	
func _exit_tree():
	Events.disconnect("tappable_entered",Callable(self,'_on_tappable_entered'))
	Events.disconnect("tappable_exited",Callable(self,'_on_tappable_exited'))
	Events.disconnect("tap",Callable(self,'_on_tap'))
	
func _on_tappable_entered(tappable, ship : Ship):
	# activate another tappable only if there isn't an older one for this ship
	if not active_tappables.has(ship):
		active_tappables[ship] = tappable
		tappable.show_tap_preview(ship) # WARNING the new color overwrites the old
	
func _on_tappable_exited(tappable, ship : Ship):
	if active_tappables.has(ship):
		var old_tappable = active_tappables[ship]
		active_tappables.erase(ship)
		
		# search if there are ships left holding the old tappable
		var found := false
		for s in active_tappables.keys():
			if active_tappables[s] == old_tappable:
				found = true
				# a ship was found, change the preview to its color
				active_tappables[s].show_tap_preview(s)
				break
				
		# if there are no more ships holding the old tappable, hide the preview
		if not found:
			old_tappable.hide_tap_preview()
		
		# check if we will be in another tappable
		await get_tree().idle_frame
		ship.recheck_colliding()

func _on_tap(ship : Ship):
	if active_tappables.has(ship):
		var tappable = active_tappables[ship]
		tappable.tap(ship)
		Events.emit_signal("sth_tapped", ship, tappable)
