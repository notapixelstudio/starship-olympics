extends Area2D
class_name Turret

@export var enabled := true:
	set(value):
		enabled = value
		_forward_firing_setting(&"enabled", value)
@export var wait_time := 2.0:
	set(value):
		wait_time = value
		_forward_firing_setting(&"wait_time", value)
@export var time_jitter := 0.0:
	set(value):
		time_jitter = value
		_forward_firing_setting(&"time_jitter", value)
@export_group("Burst")
@export var burst_shots := 1:
	set(value):
		burst_shots = value
		_forward_firing_setting(&"burst_shots", value)
@export var burst_time := 0.2:
	set(value):
		burst_time = value
		_forward_firing_setting(&"burst_time", value)
@export var burst_time_jitter := 0.0:
	set(value):
		burst_time_jitter = value
		_forward_firing_setting(&"burst_time_jitter", value)

# Ship-like "interface"
signal tap(charge:float)

func get_target_velocity() -> Vector2:
	return Vector2.ZERO
	
# end

signal alert_ended

var _pending_firing_settings := {}

func _enter_tree() -> void:
	ActorBehavior.bind_children(self)
	var firing := get_node_or_null("TurretFiring")
	if firing != null:
		for setting in _pending_firing_settings:
			firing.set(setting, _pending_firing_settings[setting])
	_pending_firing_settings.clear()

func _forward_firing_setting(setting: StringName, value: Variant) -> void:
	var firing := get_node_or_null("TurretFiring")
	if firing == null:
		_pending_firing_settings[setting] = value
	else:
		firing.set(setting, value)

func set_time(v:float) -> void:
	wait_time = v
	
func start() -> void:
	%TurretFiring.start()
	
func stop() -> void:
	%TurretFiring.stop()

func fire() -> void:
	tap.emit(0)
	
# TODO design how to handle color for rogue team
func get_color() -> Color:
	return Color.WHITE
	
func get_team() -> String:
	return 'rogue'

func alert():
	%AnimationPlayer.play("Alert")
	await %AnimationPlayer.animation_finished
	alert_ended.emit()
