extends Camera2D

export var zoomMin = 1.7
export var marginX = 0
export var marginY = 200.0
export(float, 0.1, 1.0) var zoom_offset : float = 0.9
export(float, 0.01, 0.5) var zoom_speed : float = 0.13
export(float, 0.01, 0.5) var offset_speed : float = 0.09
export var debug_mode : bool = true

var camera_rect : = Rect2()
var viewport_rect : = Rect2()

export var enabled:bool = false
var margin_min = Vector2(0,0)
var margin_max = Vector2()
var rect_extents = Vector2()
var arena_size = Vector2()

var elements_in_camera
const FRAME_DELAY = 10
var wait_in_frame = FRAME_DELAY

const IN_CAMERA = "in_camera"

func _ready():
	if enabled:
		current = true
	elements_in_camera = get_tree().get_nodes_in_group(IN_CAMERA)
	if len(elements_in_camera):
		offset = elements_in_camera[0].position
	rect_extents = Vector2(zoom.x*margin_max.x, zoom.y*margin_max.y)/2
	viewport_rect = get_viewport_rect()
	
	# let's put some distance from the battlefield and the bars
	viewport_rect.size.y -= marginY/2
	
func initialize(rect_extention:Vector2, _zoom_max:float):
	elements_in_camera = get_tree().get_nodes_in_group("players")
	arena_size = rect_extention
	margin_min = arena_size/2
	print("Offset at initialise is: ", offset)
	set_process(enabled)

func _process(_delta: float) -> void:
	elements_in_camera = get_tree().get_nodes_in_group(IN_CAMERA)
	rect_extents = Vector2(zoom.x*margin_max.x, zoom.y*margin_max.y)/2
	if len(elements_in_camera):
		camera_rect = Rect2(elements_in_camera[0].global_position, Vector2())
	for ship in elements_in_camera:
		camera_rect = camera_rect.expand(ship.global_position)
	
	var offset_to_be = calculate_center(camera_rect)
	var zoom_to_be = calculate_zoom(camera_rect, viewport_rect.size)
	if wait_in_frame < 0:
		
		offset.x = lerp(offset.x, offset_to_be.x, offset_speed)
		offset.y = lerp(offset.y, offset_to_be.y-marginY, offset_speed)
		#offset.x = clamp(offset.x, rect_extents.x, (arena_size.x-rect_extents.x))
		#offset.y = clamp(offset.y, rect_extents.y-marginY, (arena_size.y-rect_extents.y))

	else:
		pass
	
	zoom.x = lerp(zoom.x, zoom_to_be.x, zoom_speed)
	zoom.y = lerp(zoom.y, zoom_to_be.y, zoom_speed)
	zoom.x = max(zoom.x, zoomMin)
	zoom.y = max(zoom.y, zoomMin)

	if debug_mode:
		update()
	if enabled:
		current = true
	else: 
		current = false
	
	wait_in_frame-=1
	
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