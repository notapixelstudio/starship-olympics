extends AudioLibrary

func _ready():
	print("I'll be handling everything from now on. I am the master")
	
var array_songs setget , _get_songs
var current_album
var current_song

func _get_songs():
	return list_songs()

func play(sound : String = "", force_stop = false):
	if force_stop:
		stop()
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
	current_song = this_sound
	print(array_songs, current_song)

func list_songs():
	var songs = []
	if current_album:
		for song in current_album.get_children():
			songs.append(song.name)
		return songs