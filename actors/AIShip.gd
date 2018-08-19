extends "res://actors/Ship.gd"

export (int) var detect_radius = 400
var target = null
var last_rotation = ROTATION_SPEED
var counter = 0
var paused = false
var aim = false
var danger = false
const MAX_DANGER = 100

func _ready():
	var circle = CircleShape2D.new()
	$DetectRadius/CollisionShape2D.shape = circle
	$DetectRadius/CollisionShape2D.shape.radius = detect_radius
	target = get_parent().get_node("Ship")

var wr
var direction = Vector2()
var current_dir = Vector2()
var dist 
func control(delta):
	counter += 1
	wr = weakref(target)
	direction = Vector2() 
	
	if wr.get_ref():
		direction = (target.position - self.position).normalized()
		# if 2 we are in opposite direction, if 1 we are in perpendicular, if 0 we are running into it
		dist = distance(self.velocity.normalized(), direction)
		
		#var current_dir = Vector2(0, 0).rotated($Line2D.global_rotation)
		#$Line2D.global_rotation = current_dir.linear_interpolate(direction, 100 * delta).angle()
	#if not target.alive:
	#	self.alive  = false
	#	print(direction)
#		print(dist)
		#$Debug.text = str(direction.x)
	# Priority to avoid danger
	var steer_away = avoid_collision(MAX_DANGER)
	if steer_away:
		direction = (steer_away - self.position).normalized()
		dist = distance(self.velocity.normalized(), direction)
		print(dist)
		print(direction)
		# steer(last_rotation)
	if dist > 1.8 :
		if aim and fire_cooldown <= 0 :
			print(distance(-self.velocity.normalized(), direction))
			fire_cooldown = 0.2
			fire()
	elif dist >= 1.3 and dist<= 1.8:
		last_rotation = -sign(direction.y) * ROTATION_SPEED
		steer(last_rotation)
	elif  dist > 0.4 and dist < 1 :
		last_rotation = -sign(direction.y) * ROTATION_SPEED
		steer(last_rotation)
	

	move_and_collide(direction*speed_multiplier*delta) 

func distance(n1,n2):
	var distance = n1 - n2
	return(sqrt((distance.x * distance.x) + (distance.y * distance.y)))
	
func avoid_collision(proximity):
	for node in get_node('/root/Arena/Battlefield').get_children():
		if not node.is_in_group("players"):
			if distance(self.position, node.position) <= proximity:
				print("STEER AWAY")
				return(node.position)
	return Vector2()
	
func _on_DetectRadius_body_entered(body):
	if body.is_in_group("players") and body != self:
		if direction.x == 1 and direction.y == 0:
			steer(last_rotation)
		aim = true

func _on_DetectRadius_body_exited(body):
	if body.is_in_group("players") and body != self:
		aim = false