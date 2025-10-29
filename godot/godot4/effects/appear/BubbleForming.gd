extends Node2D

signal done

func _process(delta: float) -> void:
	global_rotation = 0.0

func _ready() -> void:
	await get_tree().create_tween().tween_property(self, "scale", Vector2(1,1), 0.5).set_ease(Tween.EASE_OUT).finished
	done.emit()
