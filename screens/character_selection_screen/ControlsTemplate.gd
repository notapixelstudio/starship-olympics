extends Control

func set_commands(command):
	var command_texture = load("res://assets/icon/"+command+".png")
	$commands.texture = command_texture
	show_commands()

func show_commands():
	# $CenterContainer.visible = true
	$commands.visible = true
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
