extends RayCast2D

class_name Laser

@export var checked = true :
	get:
		return checked # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_on
@export (String, 'laser', 'freeze', 'barrier') var type = 'laser' :
	get:
		return type # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_type

const FLASH_DURATION = 0.1
const WIDTH = 40
const HINT_WIDTH = 6

var off_color
var gradient
var particles_color

func set_type(v):
	type = v
	refresh_type()
	
func refresh_type():
	if type == 'laser':
		off_color = Color(1,0,0.5)
		gradient = Gradient.new()
		gradient.set_color(0, Color8(281,186,150))
		gradient.set_color(1, Color8(459,0,115))
		particles_color = Color8(938,144,100)
	elif type == 'freeze':
		off_color = Color(0,1,1)
		gradient = Gradient.new()
		gradient.set_color(0, Color8(100,180,300))
		gradient.set_color(1, Color8(0,104,500))
		particles_color = Color8(140,301,638)
	elif type == 'barrier':
		off_color = Color(1,1,1)
		gradient = Gradient.new()
		gradient.set_color(0, Color8(310,310,210))
		gradient.set_color(1, Color8(500,500,400))
		particles_color = Color8(340,340,300)

func set_on(v, duration=null):
	checked = v
	enabled = checked
	
	if not is_inside_tree():
		await self.ready
	
	$CastingParticles2D.emitting = checked
	
	if checked:
		$Line2D.modulate = Color(1,1,1)
		$CollisionParticles2D.emitting = true
	else:
		$RayArea/CollisionShape2D.disabled = true
	
	if is_inside_tree():
		$Line2D.width = WIDTH if checked else HINT_WIDTH
		await get_tree().create_timer(FLASH_DURATION).timeout
		$Line2D.width = WIDTH if not checked else HINT_WIDTH
		await get_tree().create_timer(FLASH_DURATION).timeout
		
		$Line2D.width = WIDTH if checked else HINT_WIDTH
		await get_tree().create_timer(FLASH_DURATION).timeout
		$Line2D.width = WIDTH if not checked else HINT_WIDTH
		await get_tree().create_timer(FLASH_DURATION).timeout
		
		$Line2D.width = WIDTH if checked else HINT_WIDTH
		await get_tree().create_timer(FLASH_DURATION).timeout
		$Line2D.width = WIDTH if not checked else HINT_WIDTH
		await get_tree().create_timer(FLASH_DURATION).timeout
		
		$Line2D.width = WIDTH if checked else HINT_WIDTH
		await get_tree().create_timer(FLASH_DURATION).timeout
		$Line2D.width = WIDTH if not checked else HINT_WIDTH
		await get_tree().create_timer(FLASH_DURATION).timeout
		
		$Line2D.width = WIDTH if checked else HINT_WIDTH
		await get_tree().create_timer(FLASH_DURATION).timeout
		$Line2D.width = WIDTH if not checked else HINT_WIDTH
		await get_tree().create_timer(FLASH_DURATION).timeout
	
	$Line2D.width = WIDTH if checked else HINT_WIDTH
	
	if not checked:
		$Line2D.modulate = off_color
		$CollisionParticles2D.emitting = false
	else:
		$RayArea/CollisionShape2D.disabled = false
	
	if duration:
		await get_tree().create_timer(duration).timeout
		set_on(not checked)

func _ready():
	set_physics_process(false)
	refresh_type()
	$Line2D.gradient = gradient
	$CollisionParticles2D.modulate = particles_color
	$Entity/PhaseThroughDeadly.set_enabled(type == 'laser')
	$Entity/Trigger.set_enabled(type == 'laser')
	
func start():
	set_physics_process(true)

var laser_endpoint = Vector2(0,0)
func _physics_process(delta):
	var cast_point = cast_to
	force_raycast_update()
	
	if is_colliding():
		cast_point = to_local(get_collision_point())
		
	if cast_point.length() - laser_endpoint.length() > 50:
		laser_endpoint = laser_endpoint.lerp(cast_point, delta*1000/laser_endpoint.distance_to(cast_point))
	else:
		laser_endpoint = cast_point
		
	$RayArea/CollisionShape2D.shape.b = laser_endpoint
	$Line2D.points[1] = laser_endpoint
	$CollisionParticles2D.position = laser_endpoint
	
func damage():
	if checked:
		set_on(false, 3)
		
func _on_RayArea_body_entered(body):
	if body is Bubble:
		# bubbles pop regardless of type
		body.pop(true)
	
	if type == 'freeze':
		if body.has_method('freeze') and not ECM.E(body).has('Phasing'):
			body.freeze()
	elif type == 'barrier':
		if body.has_method('rebound') and not ECM.E(body).has('Phasing'):
			body.rebound()
			
func _on_RayArea_area_entered(area):
	if area is Explosion:
		damage()

func get_strategy(ship, distance, game_mode):
	return {"avoid": 1}
	
