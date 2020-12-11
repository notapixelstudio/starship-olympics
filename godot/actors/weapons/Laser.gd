extends RayCast2D

class_name Laser

export var on = true setget set_on

const FLASH_DURATION = 0.08
const WIDTH = 40
const HINT_WIDTH = 6

func set_on(v, duration=null):
	on = v
	enabled = on
	$CastingParticles2D.emitting = on
	
	if is_inside_tree():
		$Line2D.width = WIDTH if on else HINT_WIDTH
		yield(get_tree().create_timer(FLASH_DURATION), "timeout")
		$Line2D.width = WIDTH if not on else HINT_WIDTH
		yield(get_tree().create_timer(FLASH_DURATION), "timeout")
		
		$Line2D.width = WIDTH if on else HINT_WIDTH
		yield(get_tree().create_timer(FLASH_DURATION), "timeout")
		$Line2D.width = WIDTH if not on else HINT_WIDTH
		yield(get_tree().create_timer(FLASH_DURATION), "timeout")
		
		$Line2D.width = WIDTH if on else HINT_WIDTH
		yield(get_tree().create_timer(FLASH_DURATION), "timeout")
		$Line2D.width = WIDTH if not on else HINT_WIDTH
		yield(get_tree().create_timer(FLASH_DURATION), "timeout")
	
	$Line2D.width = WIDTH if on else HINT_WIDTH
	$Area2D/CollisionShape2D.disabled = not on
	$CollisionParticles2D.emitting = on
	
	if duration:
		yield(get_tree().create_timer(duration), "timeout")
		set_on(not on)

func _ready():
	set_physics_process(true)

var laser_endpoint = Vector2(0,0)
func _physics_process(delta):
	var cast_point = cast_to
	force_raycast_update()
	
	if is_colliding():
		cast_point = to_local(get_collision_point())
		
	if cast_point.length() - laser_endpoint.length() > 50:
		laser_endpoint = laser_endpoint.linear_interpolate(cast_point, delta*1000/laser_endpoint.distance_to(cast_point))
	else:
		laser_endpoint = cast_point
		
	$Area2D/CollisionShape2D.shape.b = laser_endpoint
	$Line2D.points[1] = laser_endpoint
	$CollisionParticles2D.position = laser_endpoint
	
func damage():
	if on:
		set_on(false, 3)
		
func _on_HitArea_body_entered(body):
	# mask: if body is Bomb or body is Explosion or body is Trail:
	damage()
	
