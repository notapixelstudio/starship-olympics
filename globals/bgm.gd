extends AudioStreamPlayer

export (StreamTexture) var soundtrack = preload("res://assets/sounds/soundtracks/250143__foolboymedia__rave-digger.ogg")

func _ready():
	bgm.stream = soundtrack
