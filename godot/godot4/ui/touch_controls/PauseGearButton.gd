extends Button

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	focus_mode = Control.FOCUS_NONE
	flat = true
	pressed.connect(_trigger_pause)

func show_hint() -> void:
	visible = true
	queue_redraw()

func hide_hint() -> void:
	visible = false
	queue_redraw()

func _trigger_pause() -> void:
	for overlay in get_tree().get_nodes_in_group("pause_overlay"):
		if overlay.has_method("pause") and not overlay.paused:
			overlay.pause()

func _draw() -> void:
	if not visible:
		return
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.38
	draw_circle(center, radius, Color(1, 1, 1, 0.1))
	draw_arc(center, radius, 0.0, TAU, 48, Color(1, 1, 1, 0.28), 2.0)
	_draw_gear_icon(center, radius * 0.55)

func _draw_gear_icon(center: Vector2, radius: float) -> void:
	var teeth := 8
	var inner := radius * 0.55
	var outer := radius
	for i in teeth:
		var a0 := TAU * float(i) / float(teeth)
		var a1 := TAU * (float(i) + 0.35) / float(teeth)
		var a2 := TAU * (float(i) + 0.65) / float(teeth)
		var a3 := TAU * float(i + 1) / float(teeth)
		var pts := PackedVector2Array([
			center + Vector2(cos(a0), sin(a0)) * inner,
			center + Vector2(cos(a1), sin(a1)) * outer,
			center + Vector2(cos(a2), sin(a2)) * outer,
			center + Vector2(cos(a3), sin(a3)) * inner,
		])
		draw_colored_polygon(pts, Color(1, 1, 1, 0.45))
	draw_circle(center, inner * 0.45, Color(1, 1, 1, 0.35))
