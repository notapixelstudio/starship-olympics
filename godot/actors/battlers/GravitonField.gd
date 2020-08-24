extends Node2D

export var multiplier : float = 1.0
export var timeout : float = 0.0
export var enabled : bool = false setget set_enabled
export var gravity : float = 1024.0
export var influence_radius : float = 500.0

func _enter_tree():
	yield(get_tree().create_timer(timeout), "timeout")
	if timeout:
		enabled = false
		
func set_enabled(v):
	enabled = v
	
func get_influence_radius():
	return influence_radius
	
func get_gravity():
	if not enabled:
		return 0 
	return gravity * multiplier
	
