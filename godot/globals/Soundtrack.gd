extends AudioLibrary

func _ready():
	print_debug("I'll be handling everything from now checked. I am the master")
	
var array_songs :
	get:
		return array_songs # TODOConverter40 Copy here content of _get_songs 
	set(mod_value):
		mod_value  # TODOConverter40  Non existent set function
var current_album
var current_song :
	get:
		return current_song # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of change_song


func change_song(new_song):
	if new_song != current_song :
		play(new_song, true)
	current_song = new_song



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
				current_album = album
				found = true
				
				break
		if found:
			break
			
	current_album.play(sound)
	array_songs = list_songs()
	current_song = this_sound

func list_songs():
	var songs = []
	if current_album:
		for song in current_album.get_children():
			songs.append(song.name)
		return songs
