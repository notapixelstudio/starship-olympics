@tool
extends Line2D

var _height : float = 32.0
var _show_edges : bool = true
var _edge_points : PackedVector2Array = []

func set_height(v: float) -> void:
	_height = v
	
func set_show_edges(v: bool) -> void:
	_show_edges = v
	
func set_edge_points(v: PackedVector2Array) -> void:
	_edge_points = v

func _draw() -> void:
	if not _show_edges:
		return
		
	for point in _edge_points:
		if point.y >= 0:
			draw_line(point, point+Vector2(0,_height), Color.WHITE, width)
