tool
extends Area2D

class_name Polyomino

export var fill = Color(1,1,1) setget set_fill
export var stroke = Color(0,0,0) setget set_stroke

var order = 1

func set_fill(v):
	fill = v
	$Polygon2D.color = fill
	
func set_stroke(v):
	stroke = v
	$Line2D.default_color = stroke
	
func _ready():
	refresh()
	set_order(order)
	
func set_polygon_global(new_polygon_global):
	var new_polygon = transform.xform_inv(new_polygon_global)
	$CollisionPolygon2D.polygon = new_polygon
	refresh()
	
func refresh():
	var poly = $CollisionPolygon2D.polygon
	$Polygon2D.polygon = poly
	$Line2D.points = PoolVector2Array(Array(poly) + [poly[0]])
	
func get_polygon_global():
	return transform.xform($CollisionPolygon2D.polygon)
	
func merge(other : Polyomino):
	var result = Geometry.merge_polygons_2d(get_polygon_global(), other.get_polygon_global())
	if len(result) != 1:
		return # merge only adjacent minoes
		
	set_polygon_global(result[0])
	set_order(order + other.order)
	
func get_order():
	return order
	
func set_order(v):
	order = v
	$Wrapper/Monogram.text = str(order)
