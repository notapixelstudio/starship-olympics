@tool
extends "res://godot4/elements/walls/Wall.gd"

@export var reset_time := 5.0
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
	%Timer.start(reset_time)
	
func _on_timer_timeout() -> void:
	_turn_on()
