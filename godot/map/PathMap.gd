extends Path2D

onready var tween = $Tween
onready var follow = $PathFollow2D
export var duration : float = 2.0

signal completed

func set_points(points: PoolVector2Array):
	# This take a list of points and create a curve
	for point in points:
		self.curve.add_point(point)

func reset():
	follow.unit_offset = 0
	
func clear():
	self.curve.clear_points()

	
func animate():
	follow.add_to_group("in_camera")
	tween.interpolate_property(follow, "unit_offset", 0.0, 0.99, duration,Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_completed")
	follow.remove_from_group("in_camera")
	emit_signal("completed")
