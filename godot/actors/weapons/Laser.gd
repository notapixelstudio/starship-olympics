extends RayCast2D

class_name Laser

export var on = true setget set_on

const FLASH_DURATION = 0.08
const WIDTH = 24
const HINT_WIDTH = 6

func set_on(v):
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

func _ready():
	set_physics_process(true)

func _physics_process(delta):
	var cast_point = cast_to
	force_raycast_update()
	
	if is_colliding():
		cast_point = to_local(get_collision_point())
		
	$Area2D/CollisionShape2D.shape.b = cast_point
	$Line2D.points[1] = cast_point
	$CollisionParticles2D.position = cast_point
