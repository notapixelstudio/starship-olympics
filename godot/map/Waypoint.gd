extends MapLocation

class_name Waypoint

var locked := true # FIXME this logic should be brought up to MapLocation

func unlock():
	if locked:
		# simply notify that we have been unlocked
		Events.emit_signal("sth_unlocked", self, self)
		locked = false
	
