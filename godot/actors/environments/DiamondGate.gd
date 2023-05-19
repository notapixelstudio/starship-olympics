extends Gate

func _on_DiamondGate_crossed(by_what, gate, trigger):
	global.the_match.add_score(by_what.get_player().get_id(), 1)
	global.arena.show_msg(by_what.get_player().species, 1, by_what.position)
	queue_free()
