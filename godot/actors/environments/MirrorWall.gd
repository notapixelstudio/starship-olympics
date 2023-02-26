tool
extends Wall

class_name MirrorWall

func damage(hazard, damager):
	$AnimationPlayer.advance(10) # should be enough to end the current animation and make the sector flash again
	$AnimationPlayer.play("Hit")
