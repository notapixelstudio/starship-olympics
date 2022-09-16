extends Path2D

@onready var tween = $Tween
@onready var follow = $PathFollow2D
@onready var position_to_follow = $PathFollow2D/Marker2D
@export var duration : float = 2.0

signal completed

func add_point(point: Vector2):
	# Add one single point
	self.curve.add_point(point)
	
func set_points(points: PackedVector2Array):
	# This take a list of points and create a curve
	for point in points:
		self.curve.add_point(point)

func reset():
	follow.progress_ratio = 0
	
func clear():
	self.curve.clear_points()

	
func animate():
	position_to_follow.add_to_group("in_camera")
	tween.interpolate_property(follow, "progress_ratio", 0.0, 0.99, duration,Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	await tween.finished
	position_to_follow.remove_from_group("in_camera")
	emit_signal("completed")
