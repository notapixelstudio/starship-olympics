@tool
extends AudioStreamPlayer

@export var streams: Array[AudioStream]  # (Array, AudioStream)
@export var random_strategy = 0 # (int, "Pure", "No consecutive repetition", "Use all samples before repeat")

@export var randomize_volume: bool = false
@export var volume_min = 0 # (float, -80, 24)
@export var volume_max = 0 # (float, -80, 24)

@export var randomize_pitch: bool = false
@export var pitch_min = 1 # (float, 0.01, 32)
@export var pitch_max = 1 # (float, 0.01, 32)

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
				set_volume_db(randf_range(volume_min, volume_max))
			if randomize_pitch:
				set_pitch_scale(randf_range(pitch_min, pitch_max))
		set_stream(streams[playing_sample_nb])
		super.play(from_position)

func _ready():
	connect("finished",Callable(self,"reset_playing_sample_nb"))

func reset_playing_sample_nb():
	if playing_sample_nb >= 0:
		playing_sample_nb = -1

