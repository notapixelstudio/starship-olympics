extends Node

class_name ChargeManager

const MAX_CHARGE = 0.6

@export var max_tap_charge := 0.3
@export var min_dash_charge := 0.2

signal charged_enough_to_dash
signal charged_too_much_for_tap
signal reset_done

var _charge := 0.0
var _is_charging := false

func _physics_process(delta):
	if _is_charging:
		_charge += delta

func start_charging() -> void:
	if _is_charging:
		return 
	_is_charging = true
	$TapTimer.wait_time = max_tap_charge
	$DashTimer.wait_time = min_dash_charge
	$TapTimer.start()
	$DashTimer.start()
	
func end_charging() -> void:
	_charge = 0.0
	_is_charging = false
	$TapTimer.stop()
	$DashTimer.stop()
	emit_signal("reset_done")
	
func get_charge() -> float:
	return _charge
	
func get_charge_normalized() -> float:
	return min(get_charge(), MAX_CHARGE)/MAX_CHARGE
	
func can_tap() -> bool:
	return _charge <= max_tap_charge

func can_dash() -> bool:
	return _charge >= min_dash_charge


func _on_tap_timer_timeout():
	emit_signal("charged_too_much_for_tap")


func _on_dash_timer_timeout():
	emit_signal("charged_enough_to_dash")
