extends Area2D
class_name Ghost

func _ready() -> void:
	%AnimationPlayer.play("default")
	%AnimationPlayer.advance(randf())
