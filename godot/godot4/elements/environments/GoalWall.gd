@tool
extends "res://godot4/elements/environments/Wall.gd"

func hit(sth:Ball) -> void:
	Events.score.emit(1, sth.get_owner_ship(), sth.global_position)
	%AnimationPlayer.stop()
	%AnimationPlayer.play("hit")
	sth.apply_central_impulse(1000*sth.linear_velocity.normalized())
