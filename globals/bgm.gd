extends AudioStreamPlayer

export (StreamTexture) var soundtrack = load("res://assets/sounds/soundtracks/250143__foolboymedia__rave-digger.wav")

func _ready():
	bgm.stream = soundtrack
