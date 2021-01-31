tool
extends Area2D

class_name Polyomino

var order = 1
var player

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
		return false # merge only adjacent minoes
		
	set_polygon_global(result[0])
	set_order(order + other.order)
	return true
	
func get_order():
	return order
	
func set_order(v):
	order = v
	$Wrapper/Monogram.text = str(order)

func get_player():
	return player
	
func set_player(v):
	player = v
	if player != null:
		$Polygon2D.color = player.species.color
		$Polygon2D.modulate.a8 = 215
		#$Line2D.modulate = Color(0,0,0)
		z_index = -13
	else:
		$Polygon2D.color = Color(1,1,1)
		$Polygon2D.modulate.a8 = 30
		#$Line2D.modulate = Color(1,1,1)
		z_index = -14
		
func _process(delta):
	var found = false
	for body in get_overlapping_bodies():
		if body is Ship and Geometry.is_point_in_polygon(body.global_position, transform.xform($CollisionPolygon2D.polygon)):
			# two ships inside = no one takes it
			if found:
				set_player(null)
				break
			
			found = true
			set_player(body.get_player())
	
	if not found and get_player() != null:
		set_player(null)
		
