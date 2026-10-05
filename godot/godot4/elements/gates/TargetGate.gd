extends VBoxContainer

@export var arrow_scene : PackedScene

var _targets : Array[Player]

func add_target(player:Player) -> void:
	_targets.append(player)
	_redraw_targets()
	
func remove_target(player:Player) -> void:
	_targets.erase(player)
	_redraw_targets()
	
func _redraw_targets() -> void:
	for child in get_children():
		child.queue_free()
	
	for target in _targets:
		var arrow = arrow_scene.instantiate()
		arrow.modulate = target.get_color()
		add_child(arrow)
