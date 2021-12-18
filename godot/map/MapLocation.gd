extends Area2D

class_name MapLocation

export (String, "hidden", "locked", "unlocked") var status = TheUnlocker.HIDDEN setget set_status, get_status

func _ready():
	self.set_status(TheUnlocker.get_status("map_locations", self.get_id()))
	
func get_status():
	return status
	
func set_status(v):
	status = v
	if not is_inside_tree():
		yield(self, 'ready')
	if Engine.editor_hint:
		modulate = Color(1,1,1,1)
	elif status == TheUnlocker.UNLOCKED:
		modulate = Color(1,1,1,1)
	elif status == TheUnlocker.LOCKED:
		modulate = Color(0,0,0,0)
	else:
		modulate = Color(0,0,0,0)

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
