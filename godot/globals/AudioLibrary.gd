extends Node

class_name AudioLibrary

var this_sound:String
var current_sound : AudioStreamPlayer

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	
func play(sound : String = "", force_stop = false):
	if force_stop:
		stop()
	if sound:
		this_sound = sound
	else:
		var i = randi()%get_child_count()
		this_sound = get_child(i).name
	current_sound = get_node(this_sound)
	print("I am ", name, " and This song is ", current_sound.name, " titled ", this_sound)
	current_sound.play()

func stop():
	# since we might not know which is playing let's iterate over all the children
	for child in get_children():
		child.stop()

func list_songs():
	return get_children()

func next_song():
	pass