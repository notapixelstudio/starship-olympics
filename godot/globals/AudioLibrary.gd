extends Node
	
var this_sound:String

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	connect("finished", self, "next_song")
	
func play(sound : String = "", force_stop = false):
	if force_stop:
		stop()
	if sound:
		this_sound = sound
	else:
		var i = randi()%get_child_count()
		this_sound = get_child(i).name
	get_node(this_sound).play()

func stop():
	# since we might not know which is playing let's iterate over all the children
	for child in get_children():
		child.stop()
	
func next_song():
	pass