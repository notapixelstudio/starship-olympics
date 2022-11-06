extends Node
class_name Brain

var target_velocity := Vector2(0,0)
var rotation_request := 0.0

signal charge
signal release

func get_target_velocity() -> Vector2:
	return target_velocity
	
func get_rotation_request() -> float:
	return rotation_request
	
