extends Camera2D

func _process(delta: float) -> void:
	Events.camera_updated.emit({'zoom': zoom.x})
