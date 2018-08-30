extends "res://screens/basic_screen.gd"

func _input(event):
	if event is InputEventMouseButton or (event is InputEventKey and event.pressed):
		change_scene()