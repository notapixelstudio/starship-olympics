@tool
extends Gate
class_name HoopGate

func _on_crossed(by_what: Variant, gate: Gate, trigger: bool) -> void:
	if by_what is Ball:
		var author = by_what.get_owner_ship()
		if author == null:
			return
			
		Events.score.emit(2, author, by_what.global_position)
