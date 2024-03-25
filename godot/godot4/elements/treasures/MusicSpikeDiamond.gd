extends MusicTreasure

@export var good_texture : Texture
@export var bad_texture : Texture

var _spikey := false

func _ready():
	super._ready()
	
	if not collectable:
		put_out_spikes()
	
func every_beat() -> void:
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
