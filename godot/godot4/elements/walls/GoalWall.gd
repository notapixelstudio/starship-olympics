@tool
extends "res://godot4/elements/walls/Wall.gd"

@export var reset_time := 5.0

@onready var _ctx = ArenaScope.get_scope(self)

var _on := false

func _ready():
	super()
	_turn_on()
	
func _turn_on() -> void:
	_on = true
	%AnimationPlayer.stop(true)
	%AnimationPlayer.play("up")

func hit(ball:Ball) -> void:
	assert(ball is SquashBall)
	if _on:
		_on = false
		ball.decrease()
		%AnimationPlayer.stop(true)
		%AnimationPlayer.play("hit")
	else:
		ball.reset()
		%AnimationPlayer.stop(true)
		%AnimationPlayer.play("hit_bad")
		if ball.has_player():
			_ctx.player_failed.emit(ball.get_player())
	
	ball.push(1000)
	%Timer.start(reset_time)
	
func _on_timer_timeout() -> void:
	_turn_on()
