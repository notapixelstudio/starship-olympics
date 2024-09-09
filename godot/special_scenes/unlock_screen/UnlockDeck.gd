extends Sprite2D

signal animation_over

func first_unlock():
	$AnimationPlayer.play("squibble")
	await $AnimationPlayer.animation_finished
	emit_signal("animation_over")
	
func second_unlock():
	$AnimationPlayer.play("Unlockete")
	await $AnimationPlayer.animation_finished
	emit_signal("animation_over")
