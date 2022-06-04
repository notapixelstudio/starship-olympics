tool
extends Polygon2D

export var fg_color = Color(1,1,1,1) setget set_fg_color
export var bg_color = Color(0,0,0,1) setget set_bg_color
export var clock : bool = false setget set_clock

export var saturation : float = 1.0 setget set_saturation

onready var poly = $Polygon

onready var wells = []

func _ready():
	# grids are below the battlefield surface
	position = global.isometric_offset
	
func set_clock(v):
	clock = v
	material.set_shader_param('active', clock)
	
func set_fg_color(v):
	fg_color = v
	if not is_inside_tree():
		yield(self, 'ready')
	poly.material.set_shader_param('fg_color', fg_color)
	
func set_bg_color(v):
	bg_color = v
	if not is_inside_tree():
		yield(self, 'ready')
	poly.material.set_shader_param('bg_color', bg_color)
	
func set_points(v):
	polygon = v
	poly.polygon = v
	
func set_t(t):
	material.set_shader_param('time_left', t)
	
func set_max_timeout(t):
	material.set_shader_param('max_time', t)
	
func set_saturation(v):
	saturation = v
	if not is_inside_tree():
		yield(self, 'ready')
	poly.material.set_shader_param('saturation', saturation)

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
	if poly.material:
		poly.material.set_shader_param("wells_texture", wells_texture)
	
