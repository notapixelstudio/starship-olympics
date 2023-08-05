extends Node2D


func _on_ScreenController_transition(action, from_id, to_id):
	Events.emit_signal("analytics_event", {"id": UUID.v4(), "action": action, "from": from_id, "to": to_id}, "navigation")
	
