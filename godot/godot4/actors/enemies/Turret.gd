extends Area2D
class_name Turret

@export var enabled := true
@export var wait_time := 2.0 : set = set_time

# Ship-like "interface"
signal tap

func get_target_velocity() -> Vector2:
	return Vector2.ZERO
	
# end


func set_time(v:float) -> void:
	wait_time = v
	
func start() -> void:
	%Timer.start(wait_time)
	
func stop() -> void:
	%Timer.stop()

func _on_timer_timeout() -> void:
	if enabled:
		tap.emit()
	%Timer.start(wait_time)
	
# TODO design how to handle color for rogue team
func get_color() -> Color:
	return Color.WHITE
	
func get_team() -> String:
	return 'rogue'
