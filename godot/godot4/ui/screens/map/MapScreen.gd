extends BackScreen

@export var next_screen : PackedScene


func _on_map_arena_done() -> void:
	next.emit(next_screen.instantiate())
