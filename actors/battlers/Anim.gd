extends Position2D

onready var anim = $AnimationPlayer

func play_appear():
	anim.play("appear")
	yield(anim, "animation_finished")

func play_disappear():
	anim.play("disappear")
	yield(anim, "animation_finished")

func play_idle():
	anim.play("idle")
	yield(anim, "animation_finished")
