extends Node

var gates : Array

func start():
	gates = get_tree().get_nodes_in_group('gates')
	
	for gate in gates:
		gate.connect('crossed',Callable(self,'_on_gate_crossed'))
		
func _on_gate_crossed(by_what, gate):
	if by_what is Ship:
		global.the_match.add_score(by_what.get_player().get_id(), 1)
		global.arena.show_msg(by_what.get_player().species, 1, by_what.position)
