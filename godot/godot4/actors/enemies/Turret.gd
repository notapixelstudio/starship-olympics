extends Area2D
class_name Turret

@export var enabled := true
@export var shooting := true
@export var wait_time := 2.0 : set = set_time
@export var time_jitter := 0.0

@export_group("Burst")
@export var burst_shots := 1
@export var burst_time := 0.2
@export var burst_time_jitter := 0.0

# Ship-like "interface"
signal tap(charge:float)

func get_target_velocity() -> Vector2:
	return Vector2.ZERO
	
# end

signal alert_ended

var _burst_count := 0

func set_time(v:float) -> void:
	wait_time = v
	
func start() -> void:
	%Timer.start(wait_time)
	
func stop() -> void:
	%Timer.stop()
	
func set_shooting(v:bool) -> void:
	shooting = v

func _on_timer_timeout() -> void:
	if enabled and shooting:
		tap.emit(0)
		_burst_count += 1
		
	if _burst_count >= burst_shots:
		%Timer.start(wait_time+randf()*time_jitter)
		_burst_count = 0
	else:
		%Timer.start(burst_time+randf()*burst_time_jitter)
	
# TODO design how to handle color for rogue team
func get_color() -> Color:
	return Color.WHITE
	
func get_team() -> String:
	return 'rogue'

func alert():
	enabled = true
	%AnimationPlayer.stop()
	%AnimationPlayer.play("Alert")
	
func stand_down():
	enabled = false
	%AnimationPlayer.stop()
	%AnimationPlayer.play("RESET")
	shooting = false
