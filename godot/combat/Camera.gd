extends Camera2D

export var panSpeed = 10.0
export var speed = 6.0
export var zoomspeed = 1.0
export var zoommargin = 0.1

export var zoomMin = 1.5
export var marginX = 200.0
export var marginY = 200.0
var zoomfactor = 1.0
var zooming = false
var margin_min = Vector2(0,0)
var margin_max = Vector2(1280, 720)
var rect_extents = Vector2(1280,720)
var arena_size = Vector2()
var zoomMax = 3.0
const PADDING = 200
var ships
const FRAME_DELAY = 20
var wait_in_frame = FRAME_DELAY

func _initialize(rect_extention:Vector2, _zoom_max:float):
	ships = get_tree().get_nodes_in_group("players")
	zoomMax = _zoom_max
	arena_size = rect_extention


func get_rectangle(positions):
	var vertexA = Vector2()
	var vertexD = Vector2()
	var minx = positions[0].position.x
	var maxx = 0
	var maxy = 0
	var miny = positions[0].position.y
	for p in positions:
		minx = min(minx,p.position.x)
		maxx = max(maxx, p.position.x)
		miny = min(miny, p.position.y)
		maxy = max(maxy, p.position.y)
	return Rect2(Vector2(minx-PADDING, miny-PADDING), Vector2((maxx-minx) + 2*PADDING, (maxy-miny) + 2*PADDING))

var previous_dir = 1
func _process(delta):
	rect_extents = Vector2(zoom.x*margin_max.x, zoom.y*margin_max.y)
	$Label.text = str(zoom)
	#smooth movement
	var inpx = get_parent().get_node("Rect").rect.position.x
	wait_in_frame-=1
	if position.x <= inpx:
		inpx = 1
	else:
		inpx = -1
	if previous_dir != inpx:
		wait_in_frame = FRAME_DELAY
		previous_dir = inpx
		
	var inpy = (int(Input.is_action_pressed("ui_down"))
	                   - int(Input.is_action_pressed("ui_up")))

	if wait_in_frame < 0:
		# change position
		position.x = lerp(position.x, position.x + inpx *speed * zoom.x,speed * delta)
		position.y = lerp(position.y, position.y + inpy *speed * zoom.y,speed * delta)
		position.x = clamp(position.x, margin_min.x, (arena_size.x-rect_extents.x))
		position.y = clamp(position.y, margin_min.y, (arena_size.y-rect_extents.y))

	else:
		print("We have to wait ", wait_in_frame, " frames")
		

	
	zoomfactor -= 0.01 * zoomspeed
	#zoom in
	zoom.x = lerp(zoom.x, zoom.x * zoomfactor, zoomspeed * delta)
	zoom.y = lerp(zoom.y, zoom.y * zoomfactor, zoomspeed * delta)

	zoom.x = clamp(zoom.x, zoomMin, zoomMax)
	zoom.y = clamp(zoom.y, zoomMin, zoomMax)

	if not zooming:
		zoomfactor = 1.0


func _input(event):
	if event.is_action_pressed("ui_accept"):
		zooming = not zooming
		zoomfactor -= 0.01 * zoomspeed
	if event.is_action_pressed("ui_cancel"):
		zooming = not zooming
		zoomfactor += 0.01 * zoomspeed
	