extends Treasure

@export var good_texture : Texture
@export var bad_texture : Texture
@export var starting_beats := 0
var _beats := 0
var _even := true
var _spikey := false

func _ready():
	Events.beat.connect(_on_beat)
	
	_beats = starting_beats
	
	if not collectable:
		put_out_spikes()
	
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
		put_out_spikes()
	else:
		collectable = true
		put_spikes_back_in()

func put_out_spikes():
	_spikey = true
	solid = false
	update_solid()
	%Sprite2D.texture = bad_texture
	%CollisionShape2D.shape.radius = 55
	shine()
	
func put_spikes_back_in():
	_spikey = false
	solid = true
	update_solid()
	%Sprite2D.texture = good_texture
	%CollisionShape2D.shape.radius = 70
	shine()

func hurt(sth):
	if _spikey and sth.has_method('suffer_damage'):
		sth.suffer_damage(1)
		
		%AnimationPlayer2.stop()
		%AnimationPlayer2.play('KillFeedback')
