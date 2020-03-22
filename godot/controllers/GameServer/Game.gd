extends Node

onready var peer = $PeerInput
onready var analogics = peer.analogic
onready var players = peer.players

signal fire

func _ready():
	peer.connect("pressed_big_button", self, "_on_remote_pressed_big_button")
	peer.connect("released_big_button", self, "_on_remote_released_big_button")


func _on_remote_pressed_big_button(id: int, data):
	Input.action_press("remote{id}_fire".format({"id": id+1}))
	
func _on_remote_released_big_button(id: int, data):
	Input.action_release("remote{id}_fire".format({"id": id+1}))