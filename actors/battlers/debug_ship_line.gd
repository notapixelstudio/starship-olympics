extends Line2D


func _ready():
	_draw()

func _process(delta):
	update()
	
func _draw():
	debug_draw(Vector2(0,0), get_parent().direction1)
	
func debug_draw(from, to):
	draw_line(from * 1000, to * 1000, Color(255, 255, 0), 1)