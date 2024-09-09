extends Control

func _ready():
	await get_tree().create_timer(0.9).timeout
	# $AnimationPlayer.play("intro")

