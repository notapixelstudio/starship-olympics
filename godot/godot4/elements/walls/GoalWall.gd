@tool
extends "res://godot4/elements/walls/Wall.gd"

var _on := false

func _ready():
	super()
	_turn_on()
	
func _turn_on() -> void:
	_on = true
	%AnimationPlayer.stop(true)
	%AnimationPlayer.play("up")

func hit(sth:Ball) -> void:
	if _on:
		_on = false
		Events.score.emit(1, sth.get_owner_ship(), sth.global_position)
		%AnimationPlayer.stop(true)
		%AnimationPlayer.play("hit")
		sth.apply_central_impulse(1000*sth.linear_velocity.normalized())
		%Timer.start()
		
func _on_timer_timeout() -> void:
	_turn_on()
