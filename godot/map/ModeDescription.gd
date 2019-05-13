extends Control

func _ready():
	pass


func _on_VideoPlayer_finished():
	$Panel2/VideoPlayer.play()
