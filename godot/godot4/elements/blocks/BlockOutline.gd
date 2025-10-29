extends Line2D

const CURVE_SIZE := 100

func _ready() -> void:
	width_curve = Curve.new()
	%TopLine2D.width_curve = Curve.new()
	for i in CURVE_SIZE:
		width_curve.add_point(Vector2(float(i)/CURVE_SIZE, 0))
		%TopLine2D.width_curve.add_point(Vector2(float(i)/CURVE_SIZE, 0))

func activate() -> void:
	self_modulate = Color.WHITE
	%TopLine2D.width = 150
	
func deactivate() -> void:
	self_modulate = Color(1,1,1,0)
	%TopLine2D.width = 100
	
var _t := 0.0
const TIME_F := 8.0
const SPACE_F := 5.0
func _process(delta: float) -> void:
	for i in width_curve.get_point_count():
		width_curve.set_point_value(i, (sin((_t*TIME_F+i*TAU*SPACE_F/width_curve.get_point_count()))+1)/10.0+0.05)
		%TopLine2D.width_curve.set_point_value(width_curve.get_point_count()-i-1, (sin((_t*TIME_F+i*TAU*SPACE_F/width_curve.get_point_count()))+1)/10.0+0.05)
	_t += delta

func set_points(points:PackedVector2Array) -> void:
	super(points)
	%TopLine2D.set_points(points)
