tool
extends AudioStreamPlayer

export(Array, AudioStream) var streams 
export(int, "Pure", "No consecutive repetition", "Use all samples before repeat") var random_strategy = 0

export(bool) var randomize_volume = false
export(float, -80, 24) var volume_min = 0
export(float, -80, 24) var volume_max = 0

export(bool) var randomize_pitch = false
export(float, 0.01, 32) var pitch_min = 1
export(float, 0.01, 32) var pitch_max = 1

var playing_sample_nb : int = -1
var last_played_sample_nb : int = -1 # only used if random_strategy = 1
var to_play = [] # only used if random_strategy = 2

func play(from_position=0.0):
	playing = true
	var number_of_samples = len(streams)
	if number_of_samples > 0:
		if playing_sample_nb < 0:
			if number_of_samples == 1:
				playing_sample_nb = 0
			else:
				randomize()
				match random_strategy:
					1:
						playing_sample_nb = randi() % (number_of_samples - 1)
						if last_played_sample_nb == playing_sample_nb:
							playing_sample_nb += 1
						last_played_sample_nb = playing_sample_nb
					2:
						if len(to_play) == 0:
							for i in range(number_of_samples):
								if i != last_played_sample_nb:
									to_play.append(i)
							to_play.shuffle()
						playing_sample_nb = to_play.pop_back()
						last_played_sample_nb = playing_sample_nb
					_:
						playing_sample_nb = randi() % number_of_samples
			
			if randomize_volume:
				set_volume_db(rand_range(volume_min, volume_max))
			if randomize_pitch:
				set_pitch_scale(rand_range(pitch_min, pitch_max))
		set_stream(streams[playing_sample_nb])
		.play(from_position)

func _ready():
	connect("finished", self, "reset_playing_sample_nb")

func reset_playing_sample_nb():
	if playing_sample_nb >= 0:
		playing_sample_nb = -1

