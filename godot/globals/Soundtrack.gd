extends AudioLibrary

var array_songs setget , _get_songs
var current_album
var current_song setget change_song

func change_song(new_song):
	if new_song != current_song:
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
	current_album = get_child(0)
	var songs = []
	if current_album:
		for song in current_album.get_children():
			songs.append(song.name)
		return songs