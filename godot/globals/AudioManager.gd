extends Node2D


export var gameover : Resource
export var lobby : Resource

func play_bgm(sound: AudioStream):
	# loop should be enabled on the resource
	$"%bgm".stream = sound
	$"%bgm".volume_db = 0
	$"%bgm".play()
	

func play(sound, from_position := 0.0):
	# It can be AudioStreamPlayer | AudioStreamPlayer2D
	var audio_player = sound.duplicate()
	add_child(audio_player)
	audio_player.connect('finished', self, 'cleanup', [audio_player])
	audio_player.play(from_position)
	

func cleanup(sound):
	# It can be AudioStreamPlayer | AudioStreamPlayer2D
	sound.queue_free()

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	
	
func stop():
	# since we might not know which is playing let's iterate 
	# over all the children
	$"%bgm".stop()

func fade_out(duration=3.0):
	
	if $"%bgm".is_playing():
		return
		
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	tween.connect("finished", self, "comeback")
	tween.interpolate_property($"%bgm", "volume_db",
		0, -80, duration,
		Tween.TRANS_SINE, Tween.EASE_IN)
	tween.start()

func comeback():
	$"%bgm".volume_db=0
	
