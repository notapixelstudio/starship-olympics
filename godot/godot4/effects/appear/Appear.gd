extends Node2D

signal done

var _touched_by

func _done():
	done.emit()

func set_texture(v: Texture) -> void:
	%Sprite2D.texture = v
	
func get_texture() -> Texture:
	return %Sprite2D.texture

func _on_area_2d_area_entered(area: Area2D) -> void:
	# this is for sure a Ship's touch area, because of collision layers
	_touched_by = area.get_ship()
	
func was_touched() -> bool:
	return _touched_by != null
	
func get_toucher():
	return _touched_by

func _make_collectable() -> void:
	add_to_group("collectable")
	
