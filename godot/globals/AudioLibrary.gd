extends Node
	

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	connect("finished", self, "next_song")
	
func play(sound : String = ""):
	if sound:
		get_node(sound).play()
	else:
		var i = randi()%get_child_count()
		get_child(i).play()

func next_song():
	pass