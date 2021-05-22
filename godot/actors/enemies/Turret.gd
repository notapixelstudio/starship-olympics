extends StaticBody2D

export var weapon : PackedScene
export var speed = 400
export var rate = 1 setget set_rate
export var rotation_speed = 0.4
export var rays = 4
export var spread = 90

var direction = Vector2(1,0)


func fire():
	for r in range(rays):
		fire_angled(r*deg2rad(spread))
	
func fire_angled(angle):
	var bullet = weapon.instance()
	
	bullet.velocity = direction.rotated(angle)*speed
	
	# ugly
	get_parent().add_child(bullet)
	
func _process(delta):
	direction = direction.rotated(rotation_speed*delta)

func set_rate(v):
	rate = v
	$Timer.wait_time = 1.0/rate
	
func _on_Timer_timeout():
	fire()
	
func start():
	$Timer.start(1.0/rate)
