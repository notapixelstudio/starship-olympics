extends AudioLibrary

func _ready():
	print("I'll be handling everything from now on. I am the master")
	
var array_songs setget , _get_songs
var current_album

func _get_songs():
	print("how many times", current_album)
	
	return list_songs()

func play(sound : String = "", force_stop = false):
	var found = false
	for album in get_children():
		if sound == album.name:
			current_album = album
			break
		for song in album.get_children():
			if song.name == sound:
				print("find it, play it")
				current_album = album
				found = true
				
				break
		if found:
			break
			
	current_album.play(sound)
	array_songs = list_songs()
	print(array_songs)

func list_songs():
	if current_album:
		return current_album.get_children()