extends "res://actors/Ship.gd"

export (int) var detect_radius = 400
var last_rotation = 0
var counter = 0
var paused = false
var aim = false
var danger = false
const MAX_DANGER = 250
var steer_away

func _ready():
	add_to_group("AI")
	var circle = CircleShape2D.new()
	$DetectRadius/CollisionShape2D.shape = circle
	$DetectRadius/CollisionShape2D.shape.radius = detect_radius
	target = get_parent().get_node("Ship")

var wr
var direction = Vector2()
var current_dir = Vector2()
var dist
var pos_dist
 
func control(delta):
	counter += 1
	wr = weakref(target)
	direction = Vector2()
	if global.gameover:
		return 
	if wr.get_ref() and "position" in target:
		direction = (target.position - self.position).normalized()
		# if 2 we are in opposite direction, if 1 we are in perpendicular, if 0 we are running into it
		dist = distance(self.velocity.normalized(), direction)
		pos_dist = (target.position - self.position).normalized()
		
		#var current_dir = Vector2(0, 0).rotated($Line2D.global_rotation)
		#$Line2D.global_rotation = current_dir.linear_interpolate(direction, 100 * delta).angle()
	#if not target.alive:
	#	self.alive  = false
	#	print(direction)
#		print(dist)
		#$Debug.text = str(direction.x)
	# Priority to avoid danger
	steer_away = avoid_collision(MAX_DANGER)
	if steer_away:
		direction = (steer_away - self.position).normalized()
		dist = distance(self.velocity.normalized(), direction)
		if dist < 0.2:
			rotation_dir = last_rotation
	if dist > 1.8 :
		if aim and fire_cooldown <= 0 :
			fire_cooldown = 0.2
			fire()
	elif dist >= 1.3 and dist<= 1.8:
		last_rotation = -sign(direction.y)
		rotation_dir = last_rotation
	elif  (dist > 0.4 and dist < 1.3) or steer_away:
		last_rotation = -sign(direction.y)
		rotation_dir = last_rotation
	

func distance(n1,n2):
	var distance = n1 - n2
	return(sqrt((distance.x * distance.x) + (distance.y * distance.y)))
	
func avoid_collision(proximity):
	for node in get_parent().get_children():
		if not node.is_in_group("players") and not node is Control:
			if distance(self.position, node.position) <= proximity:
				return(node.position)
	return Vector2()

func _on_DetectRadius_area_entered(area):
	if area.is_in_group("players") and area != self:
		if direction.x == 1 and direction.y == 0:
			steer(last_rotation)
		aim = true

func _on_DetectRadius_area_exited(area):
	if area.is_in_group("players") and area != self:
		aim = false
