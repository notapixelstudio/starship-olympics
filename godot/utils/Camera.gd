extends Camera2D

export var zoomMin = 1.7
export var zoomMax: float = 0
export var marginX = 0
export var marginY = 120.0
export (float) var zoom_speed_enlarge = 0.13
export (float) var zoom_speed_shrink = 0.02
export(float, 0.1, 4.0) var zoom_offset : float = 0.75
export(float, 0.01, 0.5) var zoom_speed : float = 0.02
export(float, 0.01, 0.5) var offset_speed : float = 0.22
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
	randomize()
	curPos = position
	if enabled:
		current = true
	elements_in_camera = get_tree().get_nodes_in_group(IN_CAMERA)
	if len(elements_in_camera):
		offset = elements_in_camera[0].position
	rect_extents = Vector2(zoom.x*margin_max.x, zoom.y*margin_max.y)/2
	viewport_rect = get_viewport_rect()
	# let's put some distance from the battlefield and the bars
	viewport_rect.size.y -= marginY
	viewport_rect.size.x -= marginX
	viewport_rect.position.y += marginY
	viewport_rect.position.x += marginX

func initialize(rect_extention:Rect2):
	elements_in_camera = get_tree().get_nodes_in_group("players")
	camera_rect = rect_extention
	margin_min = arena_size/2
	offset = calculate_center(camera_rect)
	zoom = calculate_zoom(camera_rect, viewport_rect.size)
	offset.x -= marginX/2*zoom.x
	offset.y -= marginY/2*zoom.y # offset moves the camera center, which has to be corrected by half the margin
	set_process(false)

const MAX_DIST_OFFSET = 10

func _process(_delta: float) -> void:
	if isShake:
		shake_process(_delta)    
	if stop:
		return
	time+=_delta
	
	elements_in_camera = get_tree().get_nodes_in_group(IN_CAMERA)
	rect_extents = Vector2(zoom.x*margin_max.x, zoom.y*margin_max.y)/2
	if len(elements_in_camera):
		camera_rect = Rect2(elements_in_camera[0].global_position, Vector2())
	for ship in elements_in_camera:
		camera_rect = camera_rect.expand(ship.global_position)
	
	var offset_to_be = calculate_center(camera_rect)
	var zoom_to_be = calculate_zoom(camera_rect, viewport_rect.size)
	
	# offset.x = clamp(offset.x, rect_extents.x, (arena_size.x-rect_extents.x))
	# offset.y = clamp(offset.y, rect_extents.y, (arena_size.y-rect_extents.y))
	if (offset - offset_to_be).length() >  MAX_DIST_OFFSET:
		offset_speed = zoom_speed_enlarge
	else:
		offset_speed = zoom_speed_shrink
	# zoom x and y is uguale
	if zoom_to_be.x > zoom.x:
		zoom_speed = zoom_speed_enlarge
	else: 
		zoom_speed = zoom_speed_shrink
	
	zoom.x = lerp(zoom.x, zoom_to_be.x, zoom_speed)
	zoom.y = lerp(zoom.y, zoom_to_be.y, zoom_speed)
	zoom.x = max(zoom.x, zoomMin)
	zoom.y = max(zoom.y, zoomMin)
	
	if zoom_to_be.x > zoom.x:
		zoom_speed = zoom_speed_enlarge
	else: 
		zoom_speed = zoom_speed_shrink
	
	offset.x = lerp(offset.x, offset_to_be.x - marginX/2*zoom.x, offset_speed)
	offset.y = lerp(offset.y, offset_to_be.y - marginY/2*zoom.y, offset_speed)
	if zoomMax != 0 :
		#offset.x = max(offset.x, max_offset.x)
		zoom.x = min(zoom.x, zoomMax)
		zoom.y = min(zoom.y, zoomMax)
		

#	if debug_mode:
#		update()
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
		max(zoomMin, rect.size.x / viewport_size.x + zoom_offset),
		max(zoomMin, rect.size.y / viewport_size.y  + zoom_offset))
	return Vector2(max_zoom, max_zoom)


func _draw() -> void:
	if not debug_mode:
		return

	draw_rect(camera_rect, Color("#ffffff"), false)
	draw_circle(calculate_center(camera_rect), 5, Color("#ffffff"))
	draw_circle(screen_to_world(Vector2(640,300)), 100, Color(1, 0, 0, 0.4))

func activate_camera():
	set_process(enabled)
	
func world_to_screen(p : Vector2) -> Vector2:
	return (p-offset)/zoom - Vector2(-marginX/2, -marginY/2) + viewport_rect.size/2
	
func screen_to_world(p : Vector2) -> Vector2:
	var pt = p - viewport_rect.size/2
	return Vector2(pt.x+marginX/2, pt.y+marginY/2)*zoom+offset
	
export var shake_power = 10
export var shake_time = 0.5

var timeformat = "{min}:{sec}"
onready var timelabel = $TimePassed

var stop = false
var time = 0.0
var isShake = false
var curPos
var elapsedtime = 0

	
func stop_timer():
	stop = true
	
func sec_to_min(seconds: float) -> String:
	var m = int(floor(seconds/60))
	var s = int(floor(seconds))%60
	var ss: String = "0"+str(s) if s < 10 else str(s)
	return timeformat.format({"min": m, "sec": ss})
	
func shake_process(delta):
	if elapsedtime<shake_time:
		position =  Vector2(randf(), randf()) * shake_power
		elapsedtime += delta
	else:
		isShake = false
		elapsedtime = 0
		position = curPos     
		
func shake():
	elapsedtime = 0
	isShake = true
