extends Polygon2D


# Called when the node enters the scene tree for the first time.
func _ready():
	update_wells([
		Vector3(-500,-500,5.0),
		Vector3(500,0,10.0),
		Vector3(300,100,10.25),
		Vector3(0,0,11.0),
		Vector3(50,50,12.0)
	])
	
func update_wells(array):
	var wells_img = Image.new()
	wells_img.create(len(array), 1, false, Image.FORMAT_RGBF)
	wells_img.lock()
	for i in len(array):
		wells_img.set_pixel(i, 0, Color(array[i].x, array[i].y, array[i].z))
	wells_img.unlock()
	var wells_texture = ImageTexture.new()
	wells_texture.create_from_image(wells_img, 0)
	material.set_shader_param("wells_texture", wells_texture)
	
