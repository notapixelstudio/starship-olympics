extends MapLocation

class_name Waypoint

var locked := true # FIXME this logic should be brought up to MapLocation

func _on_tap(_author):
	pass

func unlock():
	if locked:
		# simply notify that we have been unlocked
		Events.emit_signal("sth_unlocked", self, self)
		locked = false
	
