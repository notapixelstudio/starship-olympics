extends Node

class_name AudioLibrary

var this_sound:String
var current_sound : AudioStreamPlayer
var current_audio

signal play_song

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	for audio_lib in get_children():
		if not is_connected("play_song",Callable(self,"song_is_playing")):
			connect("play_song",Callable(self,"song_is_playing"))
	
func play(sound : String = "", force_stop = false):
	var song = Soundtrack.current_audio
	if song and song.get_child_count() > 0:
		comeback()
			
	if force_stop:
		stop()
	if sound == name:
		# if name is the same meaning that we reached the category
		sound = ""
	if sound:
		this_sound = sound
	else:
		var i = randi()%get_child_count()
		this_sound = get_child(i).name
	current_sound = get_node(this_sound)
	if current_sound is AudioStreamPlayer:
		emit_signal("play_song", current_sound)
	current_sound.play()

func stop():
	# since we might not know which is playing let's iterate over all the children
	for child in get_children():
		child.stop()

func list_songs():
	return get_children()

func next_song():
	var i = list_songs().find(current_sound)
	get_child(i+1 % get_child_count()).play()

func song_is_playing(song):
	current_sound = song
	Soundtrack.this_sound = current_sound.name
	Soundtrack.current_audio = song

func fade_out(duration=3.0):
	if not Soundtrack.current_audio:
		return
		
	var tween = Tween.new()
	var song = Soundtrack.current_audio
	song.add_child(tween)
	tween.connect("tween_all_completed",Callable(self,"comeback"))
	tween.interpolate_property(song, "volume_db",
		0, -80, duration,
		Tween.TRANS_SINE, Tween.EASE_IN)
	tween.start()

func comeback():
	var song = Soundtrack.current_audio
	var tween = song.get_child(0)
	stop()
	song.volume_db = 0
	tween.queue_free()
