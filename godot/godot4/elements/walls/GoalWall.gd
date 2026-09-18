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

func hit(sth:TennisBall) -> void:
	if _on:
		_on = false
		sth.decrease()
		%AnimationPlayer.stop(true)
		%AnimationPlayer.play("hit")
	else:
		sth.reset()
		%AnimationPlayer.stop(true)
		%AnimationPlayer.play("hit_bad")
	
	sth.push(1000)
	%Timer.start()
	
func _on_timer_timeout() -> void:
	_turn_on()
