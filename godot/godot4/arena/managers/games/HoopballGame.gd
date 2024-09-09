extends Node

var gates : Array

func _ready():
	await get_tree().process_frame
	gates = get_tree().get_nodes_in_group('gates')
	
	for gate in gates:
		gate.connect('crossed', _on_gate_crossed)
		if gate.name != 'Gate':
			gate.disable()
			
func _on_gate_crossed(by_what, gate, trigger):
	if by_what is Ship and by_what.has_cargo(): # TBD check if ball?
		# assign points
		Events.points_scored.emit(1, by_what.get_team())
		# show feedback
		Events.message.emit(1, by_what.get_color(), by_what.global_position)
		
		gate.show_feedback()
		gate.disable()
		activate_another_random_gate(gate)
		
func activate_another_random_gate(old_gate):
	var new_gate = old_gate
	while new_gate == old_gate:
		new_gate = gates[randi() % len(gates)]
	new_gate.enable()
	
