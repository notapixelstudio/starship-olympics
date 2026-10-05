extends Node

@onready var _ctx := ArenaScope.get_scope(self)

var _ordered_gates : Array
var _progress : Dictionary # team_id(String): gate_index(int)

func _ready() -> void:
	_ordered_gates = %Course.get_children()
	
	for gate in _ordered_gates:
		gate.crossed.connect(_on_gate_crossed)
		
	await _ctx.battlefield_ready
	
	for player in _ctx.get_active_players():
		_progress[player] = 0
		_ordered_gates[0].add_target(player)
	
func _on_gate_crossed(by_what, gate:Gate, trigger:bool) -> void:
	if not (by_what is Ship):
		return
	
	var player = by_what.get_player()
	
	Events.log.emit('Gate crossed')
	if gate == _ordered_gates[_progress[player]]:
		_progress[player] = (_progress[player] + 1) % len(_ordered_gates)
		Events.score.emit(1, by_what, by_what.global_position)
		Events.log.emit('Gate %s passed: next is %s (number %d)' % [gate.name, _ordered_gates[_progress[player]].name, _progress[player]])
		gate.show_feedback()
		
		# update next gate feedback
		gate.remove_target(player)
		_ordered_gates[_progress[player]].add_target(player)
