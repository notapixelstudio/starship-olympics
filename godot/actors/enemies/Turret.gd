extends RigidBody2D

export var weapon : PackedScene
export var speed = 400
export var rate = 1.0 setget set_rate
export var rotation_speed = 0.4
export var rays = 4
export var spread = 90
export var offset = 45
export var radius = 125
export var active := true setget set_active
export var sleeping_modulate := Color(1,1,1,1) setget set_sleeping_modulate
export var autoplay := true

var ccw = +1
var direction = Vector2(1,0)

func fire():
	if not active:
		return
		
	$AnimationPlayer.stop()
	$AnimationPlayer.play("Fire")
	for r in range(rays):
		fire_angled(r*deg2rad(spread)+deg2rad(offset))
	
func fire_angled(angle):
	var bullet = weapon.instance()
	
	bullet.global_position = global_position + radius*direction.rotated(angle)
	bullet.linear_velocity = direction.rotated(angle)*speed
	
	# ugly
	get_parent().add_child(bullet)
	
func _process(delta):
	if active:
		direction = direction.rotated(rotation_speed*delta*ccw)
		set_rotation_and_stuff(rotation + rotation_speed*delta*ccw)

func set_rate(v):
	rate = v
	$Timer.wait_time = 1.0/rate
	$AnimationPlayer.playback_speed = rate
	
func set_active(v: bool):
	active = v
	$Sprite.visible = active
	$SpriteOff.visible = not active
	$Entity/Deadly.set_enabled(active)
	
func set_sleeping_modulate(v: Color):
	sleeping_modulate = v
	$SpriteOff.modulate= sleeping_modulate
	
func _on_Timer_timeout():
	fire()
	
func _ready():
	Events.connect("sth_collided_with_ship", self, '_on_sth_collided_with_ship')
	
	if autoplay:
		ccw = +1 if randf() > 0.5 else -1
		var random_angle = randf()*2*PI
		direction = direction.rotated(random_angle)
		set_rotation_and_stuff(random_angle)
		set_process(false)
		$Routine.play('Default')
	
func start():
	set_process(true)
	$Timer.start(1.0/rate)
	fire()
	
func set_rotation_and_stuff(angle):
	rotation = angle
	$SpriteOff/Eye.rotation = -rotation

func _on_Turret_body_entered(body):
	if not active and body is Bomb and self.has_node('Routine'):
		$Routine.play('Default')
