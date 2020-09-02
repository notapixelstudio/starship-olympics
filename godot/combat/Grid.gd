extends Polygon2D


# Called when the node enters the scene tree for the first time.
func _process(delta):
	update_wells([Color(-500,-500,5.0), Color(500,0,10.0)])
	
func update_wells(array):
	var wells_img = Image.new()
	wells_img.create(len(array), 1, false, Image.FORMAT_RGBF)
	wells_img.lock()
	for i in len(array):
		wells_img.set_pixel(i, 0, array[i])
	wells_img.unlock()
	var wells_texture = ImageTexture.new()
	wells_texture.create_from_image(wells_img, 0)
	material.set_shader_param("wells_texture", wells_texture)
	
