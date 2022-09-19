extends Sprite

signal animation_over

func first_unlock():
	$AnimationPlayer.play("squibble")
	yield($AnimationPlayer, "animation_finished")
	emit_signal("animation_over")
	
func second_unlock():
	$AnimationPlayer.play("Unlockete")
	yield($AnimationPlayer, "animation_finished")
	emit_signal("animation_over")
