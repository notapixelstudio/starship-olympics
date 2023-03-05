extends AudioStreamPlayer2D

export var duration := 0.5 setget set_duration
export var step := 0.1

onready var starting_pitch_scale : float = pitch_scale

func set_duration(v: float):
	duration = v
	$Timer.wait_time = duration

func play_and_rise(from_position: float = 0.0) -> void:
	SoundEffects.play(self, from_position)
	pitch_scale += step
	$Timer.stop()
	$Timer.start()

func _on_Timer_timeout():
	# reset pitch_scale
	pitch_scale = starting_pitch_scale
