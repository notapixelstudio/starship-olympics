extends Treasure
class_name MusicTreasure
## Abstract class for music-driven treasure elements.

@export var starting_beats := 0
var _beats := 0
var _even := true

func _ready():
	Events.beat.connect(_on_beat)
	_beats = starting_beats
	
func _on_beat(period: int, beat_duration: float) -> void:
	%AnimationPlayer.stop()
	%AnimationPlayer.speed_scale = 1/beat_duration
	if _even:
		%AnimationPlayer.play('Pulse')
	else:
		%AnimationPlayer.play('PulseBack')
	_beats = (_beats + 1) % period
	_even = not _even
	every_beat()
	
## Abstract method - override to provide behavior at each beat
func every_beat() -> void:
	pass
