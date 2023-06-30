extends Node2D

signal expired

var _value := 0

func start(from: int) -> void:
	_set_value(from)

func _set_value(v: int) -> void:
	_value = v
	$CountdownValue.text = str(_value)
	visible = _value > 0
	if _value > 0:
		$Timer.start()
	elif _value == 0:
		emit_signal("expired")

func _on_Timer_timeout():
	_set_value(_value - 1)
