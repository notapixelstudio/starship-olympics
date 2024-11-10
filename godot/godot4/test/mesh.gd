extends MeshInstance2D

var t := 0.0

func _process(delta) -> void:
	mesh.clear_surfaces()
	
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	
	surface_array[Mesh.ARRAY_VERTEX] = PackedVector2Array([
		Vector2(0,0),
		Vector2(200,0),
		Vector2(0,200),
		Vector2(200,200),
		Vector2(200,200),
		Vector2(400,200),
		Vector2(200,400),
		Vector2(300+100*sin(t),400)
	])
	surface_array[Mesh.ARRAY_TEX_UV] = PackedVector2Array([
		Vector2(0,0),
		Vector2(1,0),
		Vector2(0,1),
		Vector2(1,1),
		Vector2(0,0),
		Vector2(1,0),
		Vector2(0,1),
		Vector2(1,1),
	])
	surface_array[Mesh.ARRAY_INDEX] = PackedInt32Array([
		0,1,2,1,2,3,4,5,6,5,6,7
	])
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	
	t += delta
