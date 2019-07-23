extends Node

class_name AudioLibrary

var this_sound:String
var current_sound : AudioStreamPlayer

signal play_song

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	for audio_lib in get_children():
		connect("play_song", self, "song_is_playing")
	
func play(sound : String = "", force_stop = false):
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
		print_debug("I am ", name, " and This song is ", current_sound.name, " titled ", this_sound)
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
	print_debug("This song is playing: ", song.name)
	current_sound = song
	Soundtrack.this_sound = current_sound.name