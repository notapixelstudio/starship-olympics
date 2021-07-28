tool
extends Sprite

class_name PathStar

signal appeared

func _ready() -> void:
	if Engine.editor_hint:
		appear()

func appear() -> void:
	$AnimationPlayer.play('Appear')

func appeared_enough() -> void:
	emit_signal('appeared')
