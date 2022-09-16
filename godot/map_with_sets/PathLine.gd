@tool
extends Line2D

var start: Vector2
var end: Vector2
var current: Vector2 :
	get:
		return current # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_current

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
	
func appear(force: bool = false) -> void:
	var distance = start.distance_to(end)
	if force:
		self.current = end
		emit_signal("appeared")
	else:
		# constant speed
		$Tween.interpolate_property(self, 'current', current, end, distance/500, Tween.TRANS_LINEAR)
		$Tween.start()
	
func refresh() -> void:
	set_points(PackedVector2Array([start, current]))
	
func _on_Tween_tween_all_completed():
	emit_signal('appeared')
