extends Control

const EXPOSE_DURATION := 2.0
const FADE_DURATION := 0.5

onready var container := $HBoxContainer/CenterContainer
onready var tween := $Tween


func _ready() -> void:
	var total_time := 0.0
	for element in container.get_children():
		total_time += _fade_in(element, total_time)
		total_time += _fade_out(element, total_time)
	tween.start()


func _fade_in(target: Control, total_time: float) -> float:
	tween.interpolate_property(
		target,
		"modulate",
		Color.transparent,
		Color.white,
		FADE_DURATION,
		Tween.TRANS_LINEAR,
		Tween.EASE_OUT,
		total_time
	)
	return FADE_DURATION


func _fade_out(target: Control, total_time: float) -> float:
	tween.interpolate_property(
		target,
		"modulate",
		Color.white,
		Color.transparent,
		FADE_DURATION,
		Tween.TRANS_LINEAR,
		Tween.EASE_OUT,
		total_time + EXPOSE_DURATION
	)
	return FADE_DURATION + EXPOSE_DURATION
