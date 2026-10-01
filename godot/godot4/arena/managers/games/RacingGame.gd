extends Node

var _ordered_gates : Array
var _progress : Dictionary

func _ready() -> void:
	_ordered_gates = %Course.get_children()
	
	for gate in _ordered_gates:
		gate.crossed.connect(_on_gate_crossed)
		
	await Events.battle_start
	
	for ship in get_tree().get_nodes_in_group('Ship'):
		_progress[ship] = 0
	
func _on_gate_crossed(by_what, gate:Gate, trigger:bool) -> void:
	if not (by_what is Ship):
		return
	
	Events.log.emit('Gate crossed')
	if gate == _ordered_gates[_progress[by_what]]:
		_progress[by_what] = (_progress[by_what] + 1) % len(_ordered_gates)
		Events.score.emit(1, by_what, by_what.global_position)
		Events.log.emit('Gate %s passed: next is %s (number %d)' % [gate.name, _ordered_gates[_progress[by_what]].name, _progress[by_what]])
		gate.show_feedback()
