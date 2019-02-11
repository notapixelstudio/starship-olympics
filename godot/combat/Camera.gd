extends Camera2D

export var panSpeed = 10.0
export var speed = 3.0
export var zoomspeed = 0.8
export var zoommargin = 0.1

export var zoomMin = 2
export var marginX = 200.0
export var marginY = 200.0
export(float, 0.1, 0.5) var zoom_offset : float = 0.2
export var debug_mode : bool = true

var camera_rect : = Rect2()
var viewport_rect : = Rect2()

export var enabled:bool = false
var zoomfactor = 1.0
var zooming = false
var margin_min = Vector2(0,0)
var margin_max = Vector2(1280, 720)
var rect_extents = Vector2(1280,720)
var arena_size = Vector2()
var zoomMax = 1.0
const PADDING = 200
var ships
const FRAME_DELAY = 20
var wait_in_frame = FRAME_DELAY
var previous_dir = Vector2(1, 1)

func _ready():
	viewport_rect = get_viewport_rect()
	
func initialize(rect_extention:Vector2, _zoom_max:float):
	ships = get_tree().get_nodes_in_group("players")
	zoomMax = _zoom_max
	arena_size = rect_extention
	margin_min = arena_size/2
	offset = arena_size/2
	set_process(enabled)

func _process(delta: float) -> void:
	ships = get_tree().get_nodes_in_group("players")
	rect_extents = Vector2(zoom.x*margin_max.x, zoom.y*margin_max.y)/2
	camera_rect = Rect2(ships[0].global_position, Vector2())
	for ship in ships:
		camera_rect = camera_rect.expand(ship.global_position)
	
	var offset_to_be = calculate_center(camera_rect)
	var zoom_to_be = calculate_zoom(camera_rect, viewport_rect.size)
	if abs(offset_to_be.x) < abs(offset.x) or abs(offset_to_be.y) < abs(offset.y):
		wait_in_frame = FRAME_DELAY
	if wait_in_frame < 0:
		# change position
		offset.x = lerp(offset.x, offset_to_be.x,speed * delta)
		offset.y = lerp(offset.y, offset_to_be.y, speed * delta)
		offset.x = clamp(offset.x, (rect_extents.x*2 - offset.x), (arena_size.x-rect_extents.x))
		offset.y = clamp(offset.y, (rect_extents.y*2 - offset.y), (arena_size.y-rect_extents.y))
		"""
		zoom.x = lerp(zoom.x, zoom_to_be.x, zoomspeed * delta)
		zoom.y = lerp(zoom.y, zoom_to_be.y, zoomspeed * delta)
		zoom.x = clamp(zoom_to_be.x, zoomMin, zoomMax)
		zoom.y = clamp(zoom_to_be.y, zoomMin, zoomMax)
		"""
	else:
		pass
	
	
	if debug_mode:
		update()
	
	wait_in_frame-=1
	
	"""
	if wait_in_frame < 0:
		# change position
		offset.x = lerp(offset.x, offset.x + inpx *speed * zoom.x,speed * delta)
		offset.y = lerp(offset.y, offset.y + inpy *speed * zoom.y,speed * delta)
		offset.x = clamp(offset.x, margin_min.x, (arena_size.x-rect_extents.x))
		offset.y = clamp(offset.y, margin_min.y, (arena_size.y-rect_extents.y))

	else:
		print("We have to wait ", wait_in_frame, " frames")
	"""

	# zoomfactor -= 0.01 * zoomspeed
	# zoom in
	# zoom.x = lerp(zoom.x, zoom.x * zoomfactor, zoomspeed * delta)
	# zoom.y = lerp(zoom.y, zoom.y * zoomfactor, zoomspeed * delta)

	# zoom.x = clamp(zoom.x, zoomMin, zoomMax)
	# zoom.y = clamp(zoom.y, zoomMin, zoomMax)

	# if not zooming:
	#	zoomfactor = 1.0

func calculate_center(rect: Rect2) -> Vector2:
	return Vector2(
		rect.position.x + rect.size.x / 2,
		rect.position.y + rect.size.y / 2)

func calculate_zoom(rect: Rect2, viewport_size: Vector2) -> Vector2:
	var max_zoom = max(
		max(1, rect.size.x / viewport_size.x + zoom_offset),
		max(1, rect.size.y / viewport_size.y  + zoom_offset))
	return Vector2(max_zoom, max_zoom)


func _draw() -> void:
	if not debug_mode:
		return
	draw_rect(camera_rect, Color("#ffffff"), false)
	draw_circle(calculate_center(camera_rect), 5, Color("#ffffff"))