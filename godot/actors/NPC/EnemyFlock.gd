extends Node2D

var steering_control = preload("steering.gd").new()
var target_obj = null
var vel = Vector2()
var force = Vector2();
var other_bodies = []

export( String, "steering", "steering and arriving", "fleeing", "wander", "pursuit" ) var steering_mode = "steering"

func _ready():
	steering_control 
	steering_control.max_vel = 500
	steering_control.max_force = 3000

func _process( delta ):
	#if target_obj == null: return
	#target_obj = # get_viewport().get_mouse_position()
	var chase_force = Vector2()
	var cur_pos = global_position
	
	if target_obj != null:
		if steering_mode == "steering":
			chase_force = steering_control.steering( cur_pos, target_obj.position, vel, delta )
		elif steering_mode == "steering and arriving":
			chase_force = steering_control.steering_and_arriving( cur_pos, target_obj.position, vel, 50, delta )
		elif steering_mode == "fleeing":
			chase_force = steering_control.fleeing( global_position, target_obj.position, vel, 400, delta )
		elif steering_mode == "wander":
			chase_force = steering_control.wander( vel, 100, 50 )
		elif steering_mode == "pursuit":
			chase_force = steering_control.pursuit( cur_pos, target_obj.position, vel, target_obj.linear_velocity, delta )
	
	var other_pos = []
	var other_vel = []
	for o in other_bodies:
		other_pos.append( o.global_position )
		other_vel.append( o.vel )
	
	var flockforce = Vector2()
	#var separation_force = steering_control.separation( cur_pos, other_pos, 500, 30 )
	#var alignment_force = steering_control.alignment( cur_pos, other_pos, vel, other_vel, 200 )
	#var cohesion_force = steering_control.cohesion( cur_pos, other_pos, 1, 200 )
	#flockforce = separation_force + alignment_force + cohesion_force
	flockforce = steering_control.flocking( cur_pos, vel, other_pos, other_vel, \
			30*1.5, 200*1.5, \
			200*1.5, 1*1.5, \
			200*1.5, 1*1.5 )
	
	var bound_force = steering_control.rect_bound( cur_pos, vel, OS.window_size*2, 50, 10, delta )
	
	var force = chase_force + bound_force + flockforce
	force = steering_control.truncate( force, steering_control.max_force )
	vel += force * delta
	vel = steering_control.truncate( vel, steering_control.max_vel )
	var motion = Vector2()
	motion = vel * delta
	position = cur_pos + motion
	
	# rotate sprite accordingly
	if vel.x >= 0:
		set_scale( Vector2( 1, 1 ) )
		rotation =  vel.angle() - PI / 2 
	else:
		set_scale( Vector2( -1, 1 ) )
		rotation=  vel.angle() + PI / 2 

func update_flock(boid):
	if boid != self:
		other_bodies.append(boid)
	
func set_target( obj ):
	target_obj = obj