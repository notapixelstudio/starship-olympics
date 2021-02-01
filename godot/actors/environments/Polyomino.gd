tool
extends Area2D

class_name Polyomino

var order = 1
var player
var inner_polygon_global

func _ready():
	refresh()
	set_order(order)
	
func set_polygon_global(new_polygon_global):
	var new_polygon = transform.xform_inv(new_polygon_global)
	$CollisionPolygon2D.polygon = new_polygon
	refresh()
	
func refresh():
	var poly = $CollisionPolygon2D.polygon
	inner_polygon_global = transform.xform(Geometry.offset_polygon_2d(poly, -20)[0])
	$Polygon2D.polygon = fix(poly) # polygons are not drawn correctly if two points are the same
	$Line2D.points = PoolVector2Array(Array(poly) + [poly[0]])
	
func fix(poly):
	var mutable_poly = Array(poly)
	# move duplicate points
	var i = 0
	for p1 in mutable_poly:
		for j in range(i+1, len(poly)):
			var p2 = poly[j]
			if p1 == p2:
				mutable_poly[i] = Vector2(p1.x+1, p1.y)
		i += 1
		
	return PoolVector2Array(mutable_poly)
	
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
	
	var new_color
	if player != null:
		new_color = Color8(player.species.color.r8, player.species.color.g8, player.species.color.b8, 160)
		z_index = -13
	else:
		new_color = Color8(255,255,255,30)
		z_index = -14
		
	$Tween.interpolate_property($Polygon2D, "color",
		$Polygon2D.color, new_color, 0.3,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	
func _process(delta):
	var found = false
	for body in get_overlapping_bodies():
		if body is Ship and Geometry.is_point_in_polygon(body.global_position, inner_polygon_global):
			# two ships inside = no one takes it
			if found:
				set_player(null)
				break
			
			found = true
			set_player(body.get_player())
	
	if not found and get_player() != null:
		set_player(null)
		
