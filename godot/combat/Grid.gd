extends Polygon2D

onready var wells = []

func _ready():
	# grids are below the battlefield surface
	position += global.isometric_offset

func add_well(well):
	self.wells.append(Vector3(
		well.position.x,
		well.position.y,
		OS.get_ticks_msec()/1000.0
	))
	update_wells()
	yield(get_tree().create_timer(3), "timeout")
	self.wells.pop_front()

func update_wells():
	var array = self.wells
	var wells_img = Image.new()
	wells_img.create(len(array), 1, false, Image.FORMAT_RGBF)
	wells_img.lock()
	for i in len(array):
		wells_img.set_pixel(i, 0, Color(array[i].x, array[i].y, array[i].z))
	wells_img.unlock()
	var wells_texture = ImageTexture.new()
	wells_texture.create_from_image(wells_img, 0)
	material.set_shader_param("wells_texture", wells_texture)
	
func _process(_delta):
	material.set_shader_param('time', OS.get_ticks_msec()/1000.0)
	
