extends Node2D

@export var enabled : bool = false : set = set_enabled, get = get_enabled
@export var gravity : float = 1024.0
@export var influence_radius : float = 500.0

func set_enabled(v):
	enabled = v
	if enabled:
		add_to_group("gravity_wells")
	else:
		remove_from_group("gravity_wells")
	
func enable():
	set_enabled(true)
	
func disable():
	set_enabled(false)
	
func get_enabled():
	return enabled
	
func get_influence_radius():
	return influence_radius
	
func get_gravity():
	return gravity
	
