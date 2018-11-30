extends Line2D

var from = Vector2()
var to = Vector2()
func _ready():
	pass

func _process(delta):
	from = get_parent().get_node("Ship").global_position
	to = get_parent().get_node("AIShip").global_position
	update()
	
func _draw():
	debug_draw(from, to)
	
func debug_draw(from, to):
	draw_line(from * 1000, to * 1000, Color(255, 0, 0), 1)