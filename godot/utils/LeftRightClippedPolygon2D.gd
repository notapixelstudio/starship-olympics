extends Polygon2D

@export var shape_path : NodePath
@export (String, 'left', 'right') var side = 'left'

var shape : GShape = null

func _ready():
	shape = get_node(shape_path)

func _process(delta):
	if not shape:
		return
		
	var points = shape.to_closed_PoolVector2Array()
	var result = []
	for p in points:
		if side == 'left':
			result.append(Vector2(min(0, p.x), p.y))
		elif side == 'right':
			result.append(Vector2(max(0, p.x), p.y))
			
	self.polygon = PackedVector2Array(result)
