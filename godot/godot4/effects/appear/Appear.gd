extends Node2D

signal done

func _done():
	done.emit()

func set_texture(v: Texture) -> void:
	%Sprite2D.texture = v
	
func get_texture() -> Texture:
	return %Sprite2D.texture
