extends Area2D

class_name MapLocation

func get_id() -> String:
	return self.name

func get_global_polygon() -> PoolVector2Array:
	var points = []
	for p in $CollisionPolygon2D.polygon:
		points.append(to_global(p))
	return PoolVector2Array(points)
	
func tap(_author):
	pass
	
func show_tap_preview(_author):
	pass
	
func hide_tap_preview():
	pass
	
func _on_MapLocation_body_entered(body):
	if body is Ship:
		Events.emit_signal("tappable_entered", self, body)
		
func _on_ExitArea_body_exited(body):
	if body is Ship:
		Events.emit_signal("tappable_exited", self, body)

func get_status():
	return TheUnlocker.HIDDEN
