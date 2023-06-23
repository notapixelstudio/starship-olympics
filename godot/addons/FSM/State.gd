extends Node
class_name State

export var async := false # if async, the State must emit 'exited' when its exit is done

signal exited

func enter():
	pass
	
func exit():
	pass
	
	
func transition_to(new_state_name : String) -> void:
	get_state_machine().transition_to(new_state_name)

func get_state_machine():
	return get_parent()
	
func get_host():
	return get_state_machine().get_host()
	
func is_aync() -> bool:
	return async
	
