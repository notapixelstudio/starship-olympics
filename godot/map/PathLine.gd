tool
extends Line2D

var start: Vector2
var end: Vector2
var current: Vector2 setget set_current

signal appeared

func _ready() -> void:
	if Engine.editor_hint:
		appear()

func set_current(v: Vector2) -> void:
	current = v
	refresh()

func set_endpoints(start_: Vector2, end_: Vector2) -> void:
	start = start_
	end = end_
	
	# the line is born with both points at start, ready to be animated
	current = start
	refresh()
	
func appear() -> void:
	var distance = start.distance_to(end)
	
	# constant speed
	$Tween.interpolate_property(self, 'current', current, end, distance/500, Tween.TRANS_LINEAR)
	$Tween.start()
	
func refresh() -> void:
	set_points(PoolVector2Array([start, current]))
	
func _on_Tween_tween_all_completed():
	emit_signal('appeared')
