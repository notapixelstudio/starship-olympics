extends CanvasItem
var rect = Rect2(Vector2(50,50),Vector2(200,200))
var color = Color(1.0,0.0,0.0,0.4)

func _draw():
	draw_rect(rect,color)

func _ready():
  update()

func _process(delta):
	update()