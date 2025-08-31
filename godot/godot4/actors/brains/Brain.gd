extends Node2D
class_name Brain

var target_velocity : Vector2
var rotation_request : float

var controllee
@export var enabled := true

func _enter_tree():
	controllee = get_parent()
	
func set_controllee(v) -> void:
	controllee = v
	
func set_enabled(v:bool) -> void:
	enabled = v

func get_target_velocity() -> Vector2:
	return target_velocity
	
func get_rotation_request() -> float:
	return rotation_request
	
func tick() -> void:
	pass

func start() -> void:
	enabled = true
