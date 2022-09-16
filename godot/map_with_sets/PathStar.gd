@tool
extends Sprite2D

class_name PathStar

signal appeared

func _ready() -> void:
	if Engine.editor_hint:
		appear()

func appear(force: bool = false) -> void:
	$AnimationPlayer.play('Appear')
	if force:
		$AnimationPlayer.advance($AnimationPlayer.get_animation("Appear").length)
		

func appeared_enough() -> void:
	emit_signal('appeared')
