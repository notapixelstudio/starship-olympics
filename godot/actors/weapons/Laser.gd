extends RayCast2D

class_name Laser

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
