extends Node2D

@export var enabled : bool = false : set = set_enabled, get = get_enabled
@export var attract_bodies : bool = false : set = set_attract_bodies
@export var gravity : float = 1024.0 : set = set_gravity
@export var center := Vector3(0,0,0) : set = set_center
@export var influence_radius : float = 500.0 : set = set_influence_radius
@export var source : Node
@export var source_strength_method_name : String = 'get_strength'

func set_enabled(v):
	enabled = v
	refresh()
	
func refresh():
	if enabled:
		add_to_group("gravity_wells")
		%CollisionShape2D.disabled = not attract_bodies
	else:
		remove_from_group("gravity_wells")
		%CollisionShape2D.disabled = false
		
func set_attract_bodies(v):
	attract_bodies = v
	refresh()
	
func set_gravity(v: float) -> void:
	gravity = v
	%Area2D.gravity = v*2.0
	
func set_center(v: Vector3) -> void:
	center = v
	%Area2D.gravity_point_center = Vector2(v.x, v.y)
	
func set_influence_radius(v: float) -> void:
	influence_radius = v
	%CollisionShape2D.shape.radius = v
	
func enable():
	set_enabled(true)
	
func disable():
	set_enabled(false)
	
func get_enabled():
	return enabled
	
func get_influence_radius():
	return influence_radius
	
func get_gravity():
	if not source:
		return gravity
		
	return gravity * source.get(source_strength_method_name).call()
	
func get_position_3d() -> Vector3:
	return center + Vector3(global_position.x, global_position.y, 0)
	
func get_force(application_point:Vector3) -> Vector3:
	var distance = get_position_3d() - application_point
	var surface_distance = Vector2(distance.x, distance.y)
	if surface_distance.length() < get_influence_radius():
		return distance * Utils.sigmoid(surface_distance.length(), get_influence_radius()) * get_gravity()
	return Vector3.ZERO
