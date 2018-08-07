extends "res://actors/Ship.gd"

onready var target = get_parent().get_node("Ship")
var last_rotation = ROTATION_SPEED

func control(delta):
	var wr = weakref(target)
	var direction = Vector2() 
	if wr.get_ref():
		direction = (target.position - self.position).normalized()
		
	if (direction.x > 0 and direction.y < 0) or (direction.x < 0 and direction.y > 0):
		steer(-ROTATION_SPEED)
		last_rotation = -ROTATION_SPEED
		pause_mode=true
	elif (direction.x < 0 and direction.y < 0) or (direction.x > 0 and direction.y > 0):
		steer(ROTATION_SPEED)
		last_rotation= ROTATION_SPEED
	if direction.x == 1 or direction.y ==1:
		pass
	if fire_cooldown <= 0 :
		fire()
		fire_cooldown = 0.2
	var steer_away = avoid_collision(100)
	if steer_away:
		print(steer_away)
		steer(-last_rotation)
	move_and_collide(direction*speed_multiplier*delta) 

func distance(n1,n2):
	var distance = n1.position - n2.position
	return(sqrt((distance.x * distance.x) + (distance.y * distance.y)))
	
func avoid_collision(proximity):
	for node in get_node('/root/Arena/Battlefield').get_children():
		if node.has_method("_on_Explosion_body_entered"):
			if distance(self, node) <= proximity:
				print("STEER AWAY")
				return(distance(self, node))
	return Vector2()