extends NavigationRegion2D

var _dirty := false

func set_polygon(polygon):
	navigation_polygon.clear_outlines()
	navigation_polygon.add_outline(polygon)
	
	_dirty = true

func _on_timer_timeout() -> void:
	if _dirty:
		bake_navigation_polygon()
		_dirty = false
