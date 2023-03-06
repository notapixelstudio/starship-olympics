extends Particles2D

func go():
	$AnimationPlayer.play("Fade")
	visible = true
	emitting = true
	
