tool
extends Line2D

const PathStar = preload('res://map/PathStar.tscn')
const D = 25

func set_points(v):
	points = v
	refresh()
	
func _ready():
	refresh()
	
func refresh():
	for child in get_children():
		child.queue_free()
		
	# add a smaller line to each segment
	for i in range(len(points)-1):
		add_line(points[i], points[i+1])
	
	# add a star to each internal corner
	var i = 0
	for p in points:
		i += 1
		if i == 1 or i == len(points):
			continue
		
		var star = PathStar.instance()
		star.position = p
		add_child(star)

func add_line(p1, p2):
	var dir = (p2-p1).normalized()
	
	var line = Line2D.new()
	line.add_point(p1+dir*D)
	line.add_point(p2-dir*D)
	line.width = 6
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.default_color = Color(0.6,0.6,1,0.3)
	add_child(line)
