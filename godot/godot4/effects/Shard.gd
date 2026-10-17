extends RigidBody2D

func set_texture(v: Texture) -> void:
	# setup polygons & collision shapes
	$Polygon2D.texture = v
	$Polygon2D.texture_offset = v.get_size()/2
	
func set_polygon(v) -> void:
	$Polygon2D.polygon = v
	# shrink polygon so that the collision shapes don't overlapp
	var shrunk_triangles = Geometry2D.offset_polygon(v, -2)
	if shrunk_triangles.size() > 0:
		$CollisionPolygon2D.polygon = shrunk_triangles[0]
	else:
		$CollisionPolygon2D.polygon = v
