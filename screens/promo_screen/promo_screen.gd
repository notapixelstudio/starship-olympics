extends "res://screens/basic_screen.gd"

func _input(event):
	if event.is_action_pressed("ui_accept"):
		set_process_input(false)
		change_scene()

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
