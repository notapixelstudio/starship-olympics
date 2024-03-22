extends Treasure

@export var starting_beats := 0
var _beats := 0
var _even := true

func _ready():
	Events.beat.connect(_on_beat)
	
	_beats = starting_beats
	
	if not collectable:
		phase_out()
	
func _on_beat(period: int, beat_duration: float) -> void:
	%AnimationPlayer.stop()
	%AnimationPlayer.speed_scale = 1/beat_duration
	if _even:
		%AnimationPlayer.play('Pulse')
	else:
		%AnimationPlayer.play('PulseBack')
	_beats = (_beats + 1) % period
	_even = not _even
	if _beats == 0:
		switch()
	
func switch():
	if collectable:
		collectable = false
		phase_out()
	else:
		collectable = true
		phase_in()

func phase_out():
	%Sprite2D.modulate = Color('#45c2ff2d')
	%CollisionShape2D.disabled = true
	
func phase_in():
	%Sprite2D.modulate = Color.WHITE
	%CollisionShape2D.disabled = false
	shine()
