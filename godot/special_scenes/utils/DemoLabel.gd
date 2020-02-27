extends Label

onready var anim = $AnimationPlayer
func blink():
	anim.play("Blink")