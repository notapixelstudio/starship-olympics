extends Node
class_name StateMachine

var current_state : State
var states := {}

func _ready():
	for child in get_children():
		if child is State:
			states[child.name] = child
			
	current_state = get_child(0)
	current_state.enter()
	
func transition_to(new_state_name : String) -> void:
	if not states.has(new_state_name): # invalid state name
		return
	var new_state = states[new_state_name]
	if new_state == current_state: # already the current state
		return
		
	current_state.exit()
	if current_state.is_async():
		yield(current_state, 'exited')
	current_state = new_state
	current_state.enter()
	
func get_current_state() -> State:
	return current_state

func get_host():
	return get_parent()
