extends StaticBody2D
class_name Block

const ANGLE_TOLERANCE := PI/3
const DIRS := [Vector2.DOWN,Vector2.LEFT,Vector2.UP,Vector2.RIGHT]

var _pushable := true

func push_by(ship: Ship) -> void:
	if not _pushable:
		return
		
	#var ship_dir = Vector2.RIGHT.rotated(ship.global_rotation)
	#
	#if abs(ship_dir.angle_to(Vector2.UP)) < ANGLE_TOLERANCE:
		#move.call_deferred(Vector2.UP)
	#elif abs(ship_dir.angle_to(Vector2.DOWN)) < ANGLE_TOLERANCE:
		#move.call_deferred(Vector2.DOWN)
	#elif abs(ship_dir.angle_to(Vector2.RIGHT)) < ANGLE_TOLERANCE:
		#move.call_deferred(Vector2.RIGHT)
	#elif abs(ship_dir.angle_to(Vector2.LEFT)) < ANGLE_TOLERANCE:
		#move.call_deferred(Vector2.LEFT)
		
	var sp = ship.global_position
	var bp = global_position
	var polygon = %CollisionPolygon2D.polygon
	var direction = null
	
	for i in range(len(polygon)):
		var a = to_global(polygon[i])
		var b = to_global(polygon[(i+1) % len(polygon)])
		
		var crossing_point = Geometry2D.segment_intersects_segment(sp, bp, a, b)
		if crossing_point != null:
			direction = DIRS[i]
			break
			
	if direction != null and direction != Vector2.UP:
		move.call_deferred(direction)
	
func move(dir:Vector2) -> void:
	global_position += 200 * dir
	_pushable = false
	%Timer.start()
	Events.log.emit('Block pushed')

func _on_timer_timeout() -> void:
	_pushable = true


func _on_fall_timer_timeout() -> void:
	move(Vector2.DOWN)
