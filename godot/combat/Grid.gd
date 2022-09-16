@tool
extends Polygon2D

@export var fg_color = Color(1,1,1,1) :
	get:
		return fg_color # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_fg_color
@export var bg_color = Color(0,0,0,1) :
	get:
		return bg_color # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_bg_color
@export var clock : bool = false :
	get:
		return clock # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_clock

@export var saturation : float = 1.0 :
	get:
		return saturation # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_saturation

@onready var poly = $Polygon

@onready var wells = []

func _ready():
	# grids are below the battlefield surface
	position = global.isometric_offset
	
func set_clock(v):
	clock = v
	material.set_shader_parameter('active', clock)
	
func set_fg_color(v):
	fg_color = v
	if not is_inside_tree():
		await self.ready
	poly.material.set_shader_parameter('fg_color', fg_color)
	
func set_bg_color(v):
	bg_color = v
	if not is_inside_tree():
		await self.ready
	poly.material.set_shader_parameter('bg_color', bg_color)
	
func set_points(v):
	polygon = v
	poly.polygon = v
	
func set_t(t):
	material.set_shader_parameter('time_left', t)
	
func set_max_timeout(t):
	material.set_shader_parameter('max_time', t)
	
func set_saturation(v):
	saturation = v
	if not is_inside_tree():
		await self.ready
	poly.material.set_shader_parameter('saturation', saturation)

func add_well(well):
	self.wells.append(Vector3(
		well.position.x,
		well.position.y,
		Time.get_ticks_msec()/1000.0
	))
	update_wells()
	await get_tree().create_timer(3).timeout
	self.wells.pop_front()

func update_wells():
	var array = self.wells
	var wells_img = Image.new()
	wells_img.create(len(array), 1, false, Image.FORMAT_RGBF)
	false # wells_img.lock() # TODOConverter40, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed
	for i in len(array):
		wells_img.set_pixel(i, 0, Color(array[i].x, array[i].y, array[i].z))
	false # wells_img.unlock() # TODOConverter40, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed
	var wells_texture = ImageTexture.new()
	wells_texture.create_from_image(wells_img) #,0
	if poly.material:
		poly.material.set_shader_parameter("wells_texture", wells_texture)
	
