extends Node

var gates : Array

func _ready():
	yield(get_tree(), "idle_frame")
	gates = get_tree().get_nodes_in_group('gates')
	
	for gate in gates:
		gate.connect('crossed', self, '_on_gate_crossed')
		if gate.name != 'Gate':
			gate.disable()
			
func _on_gate_crossed(by_what, gate, trigger):
	if by_what is Ship:
		var holdable = by_what.get_cargo().get_holdable()
			
		if holdable != null and holdable is Ball:
			global.the_match.add_score(by_what.get_player().get_id(), 1)
			global.arena.show_msg(by_what.get_player().species, 1, by_what.position)
			gate.show_feedback()
			gate.disable()
			activate_another_random_gate(gate)
			
func activate_another_random_gate(old_gate):
	var new_gate = old_gate
	while new_gate == old_gate:
		new_gate = gates[randi() % len(gates)]
	new_gate.enable()
	
