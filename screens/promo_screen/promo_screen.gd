extends "res://screens/basic_screen.gd"

func _input(event):
	if event.is_action_pressed("ui_accept"):
		set_process_input(false)
		$AnimationPlayer.play("ready")
		yield($AnimationPlayer,"animation_finished")
		change_scene()

func _ready():
	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")
	var joypads = Input.get_connected_joypads()
	print(joypads)
	if joypads:
		print("NOT")
		$Control.visible = not $Control.visible

func _on_joy_connection_changed(device_id, connected):
	$Control.visible = not $Control.visible
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
